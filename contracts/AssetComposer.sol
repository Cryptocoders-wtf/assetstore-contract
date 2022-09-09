// SPDX-License-Identifier: MIT

/*
 * AssetComposer allows developers to create a composition from a collection of
 * assets provided by registered asset providers.
 * 
 * IAssetComposer is the interface for the consumer of this composition service. 
 * IAssetProvider is the interface each asset provider implements.
 * IAssetProviderRegistry is the interface to register various asset providers (to AssetComposer).
 * AssetComposer implements IAssetProvider interface as well, and registers itself.  
 *
 * Created by Satoshi Nakajima (@snakajima)
 */

pragma solidity ^0.8.6;

import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import { IAssetStore, IAssetStoreEx } from './interfaces/IAssetStore.sol';
import { IStringValidator } from './interfaces/IStringValidator.sol';
import { IAssetProvider, IAssetProviderRegistry, IAssetComposer } from './interfaces/IAssetComposer.sol';
import "@openzeppelin/contracts/utils/Strings.sol";
import '@openzeppelin/contracts/interfaces/IERC165.sol';

abstract contract AssetComposerCore is IAssetProviderRegistry, IERC165 {
  uint256 nextProvider; // 0-based
  mapping(string => uint256) providerIds; // key => providerId+1
  mapping(uint256 => IAssetProvider) providers;

  IAssetStoreEx public immutable assetStore; // for IStringValidator

  constructor(IAssetStoreEx _assetStore) {
    assetStore = _assetStore;
  }

  function registerProvider(IAssetProvider _provider) external override returns(uint256 providerId) {
    IAssetProvider.ProviderInfo memory providerInfo = _provider.getProviderInfo();
    providerId = providerIds[providerInfo.key];
    if (providerId != 0) {
      // Update
      providerId--; // change it to 0-based
      IAssetProvider existingProvider = providers[providerId];
      require(_provider.getOwner() == existingProvider.getOwner(), "AssetComposer:registerProvider, already registered");
      providers[providerId] = _provider;
      emit ProviderUpdated(msg.sender, providerId);
    } else {
      // New Registration
      require(_provider == providerInfo.provider, "AssetComposer:registerProvider, address mismatch");
      providers[nextProvider++] = _provider;
      providerIds[providerInfo.key] = nextProvider; // @notice: providerID + 1
      providerId = nextProvider - 1; 
      emit ProviderRegistered(msg.sender, providerId);
    }
  }

  function providerCount() external view override returns(uint256) {
    return nextProvider;
  }

  function getProvider(uint256 _providerId) public view override returns(IAssetProvider.ProviderInfo memory) {
    IAssetProvider provider = providers[_providerId];
    return provider.getProviderInfo();
  }

  function getProviderId(string memory _key) public view override returns(uint256) {
    uint256 idPlusOne = providerIds[_key];
    require(idPlusOne > 0, string(abi.encodePacked("AssestComposer:getProviderId, the provider does not exist:", _key)));
    return idPlusOne - 1;
  }
}

abstract contract AssetComposerAdmin is AssetComposerCore, Ownable {
  // Upgradable admin (only by owner)
  address public admin;

  /*
   * It allows us to disable indivial assets, just in case. 
   */
  mapping(uint256 => bool) disabled;

  constructor(IAssetStoreEx _assetStore) AssetComposerCore(_assetStore) {
    admin = owner();
  }

  modifier onlyAdmin() {
    require(owner() == _msgSender() || admin == _msgSender(), "AssetComposer: caller is not the admin");
    _;
  }

  function setAdmin(address _admin) external onlyOwner {
    admin = _admin;
  }  

  function setDisabled(uint256 _compositionId, bool _status) external onlyAdmin {
    disabled[_compositionId] = _status;
  }

  modifier enabled(uint256 _compositionId) {
    require(disabled[_compositionId] != true, "AssetComposer: this composition is diabled");
    _;    
  }
}

contract AssetComposer is AssetComposerAdmin, IAssetComposer, IAssetProvider {
  using Strings for uint256;
  using Strings for uint8;

  struct ProviderAsset {
    uint128 providerId;
    uint128 assetId;
  }

  uint256 public nextCompositionId;
  mapping(uint256 => uint256) internal layerCounts; 
  mapping(uint256 => mapping(uint256 => ProviderAsset)) internal assets;
  mapping(uint256 => mapping(uint256 => bytes)) internal transforms; // optional
  mapping(uint256 => mapping(uint256 => bytes)) internal fills; // optinoal
  mapping(uint256 => mapping(uint256 => uint256)) internal strokes; // optinoal

  constructor(IAssetStoreEx _assetStore) AssetComposerAdmin(_assetStore) {
  }

  /**
    * @notice register a new composition by specifying asset layers.
    */
  function registerComposition(AssetLayer[] memory _layers) external override returns(uint256 compositionId) {
    IStringValidator validator = assetStore.getStringValidator();
    compositionId = nextCompositionId++;
    layerCounts[compositionId] = _layers.length;

    for (uint256 i=0; i<_layers.length; i++) {
      AssetLayer memory info = _layers[i];
      uint256 assetId = info.assetId;
      uint256 providerId = getProviderId(info.provider);
      assets[compositionId][i] = ProviderAsset(uint128(providerId), uint128(assetId)); 
      bytes memory transform = bytes(info.transform);
      if (transform.length > 0) {
        require(validator.validate(transform), "register: Invalid transform");
        transforms[compositionId][i] = transform;
      }
      bytes memory fill = bytes(info.fill);
      if (fill.length > 0) {
        require(validator.validate(fill), "register: Invalid fill");
        fills[compositionId][i] = fill;
      }
      if (info.stroke > 0) {
        strokes[compositionId][i] = info.stroke;
      }
    }
    emit CompositionRegistered(msg.sender, compositionId);
  }

  function getOwner() external override view returns (address) {
    return owner();
  }

  function getProviderInfo() external view override returns(ProviderInfo memory) {
    return ProviderInfo("comp", "Asset Composer", this);
  }

  /**
    * @notice returns a SVG part (and the tag) that represents the specified composition.
    */
  function generateSVGPart(uint256 _compositionId) public view override(IAssetComposer, IAssetProvider) enabled(_compositionId) returns(string memory, string memory) {
    uint256 layerLength = layerCounts[_compositionId];
    bytes memory defs;
    bytes memory uses;
    string memory svgPart;
    string memory tagId;
    bytes32[] memory alreadyDefined = new bytes32[](layerLength);

    for (uint256 i=0; i < layerLength; i++) {
      ProviderAsset memory asset = assets[_compositionId][i];
      ProviderInfo memory info = getProvider(uint256(asset.providerId));
      (svgPart, tagId) = info.provider.generateSVGPart(uint256(asset.assetId));
      // extra {} to reduced the total amount of stack variables
      {
        // Skip if the same asset has been already defined
        bytes32 hash = keccak256(abi.encodePacked(tagId));
        bool isNewTag = true;
        for (uint256 j=0; j<i; j++) {
          if (alreadyDefined[j] == hash) {
            isNewTag = false;
            break;
          }
        }
        if (isNewTag) {
          defs = abi.encodePacked(defs, svgPart);
          alreadyDefined[i] = hash;
        }
      }
      uses = abi.encodePacked(uses, ' <use href="#', tagId, '"');
      {
        bytes memory option = transforms[_compositionId][i];
        if (option.length > 0) {
          uses = abi.encodePacked(uses, ' transform="', option, '"');
        }
        option = fills[_compositionId][i];
        if (option.length > 0) {
          uses = abi.encodePacked(uses, ' fill="', option, '"');
        }
      }
      {
        uint256 stroke = strokes[_compositionId][i];
        if (stroke > 0) {
          uses = abi.encodePacked(uses, ' stroke="black" stroke-linecap="round" stroke-width', uint8(stroke).toString(), 'px"');
        }
      }
      uses = abi.encodePacked(uses, ' />\n');
    }
    tagId = string(abi.encodePacked('comp', _compositionId.toString()));
    svgPart = string(abi.encodePacked(
      defs,
      '<g id="', tagId, '" >\n',
      uses,
      '</g>\n'
    ));    
    return (svgPart, tagId);
  }

  function totalSupply() external view override returns(uint256) {
    return nextCompositionId;
  }

  function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
      return
          interfaceId == type(IAssetProviderRegistry).interfaceId ||
          interfaceId == type(IAssetComposer).interfaceId ||
          interfaceId == type(IAssetProvider).interfaceId ||
          interfaceId == type(IERC165).interfaceId;
  }

  /**
   * Distribute the payout equally among all the asser providers of a composition.
   * _compositionId specifies the composition.
   * _skipIndex optionally specifies the asset to be skipped.  
   */
  function processPayout(uint256 _compositionId, uint256 _skipIndex) external override payable {
    uint256 layerLength = layerCounts[_compositionId];
    uint256 payout = msg.value / layerLength;

    if (_skipIndex < layerLength && layerLength > 1) {
      payout = msg.value / (layerLength - 1);
    }
    if (payout == 0) {
      return;
    }
    for (uint256 i=0; i < layerLength; i++) {
      if (i == _skipIndex) {
        continue;
      }
      ProviderAsset memory asset = assets[_compositionId][i];
      ProviderInfo memory info = getProvider(uint256(asset.providerId));
      info.provider.processPayout{value:payout}(asset.assetId, 1e10);
    }
  }  
}
