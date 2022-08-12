// SPDX-License-Identifier: MIT

/*
 * AssetComposer allows developers to create a composition from a collection of
 * assets (in AssetStore) and compositions.
 *
 * Created by Satoshi Nakajima (@snakajima)
 */

pragma solidity ^0.8.6;

import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import { IAssetStore, IAssetStoreEx } from './interfaces/IAssetStore.sol';
import { IStringValidator } from './interfaces/IStringValidator.sol';
import { IAssetProvider, IAssetProviderRegistry, IAssetComposer } from './interfaces/IAssetComposer.sol';
import "@openzeppelin/contracts/utils/Strings.sol";

// IAssetProvider wrapper of AssetStore
contract AssetStoreProvider is IAssetProvider {
  IAssetStoreEx public immutable assetStore;

  constructor(IAssetStoreEx _assetStore) {
    assetStore = _assetStore;
  }

  function generateSVGPart(uint256 _assetId) external view override returns(string memory svgPart, string memory tag) {
    IAssetStore.AssetAttributes memory attr = assetStore.getAttributes(_assetId);
    tag = attr.tag;
    svgPart = assetStore.generateSVGPart(_assetId, tag);
  }

  function totalSupply() external view override returns(uint256) {
    return assetStore.getAssetCount();
  }
}

abstract contract AssetComposerCore is IAssetProviderRegistry {
  mapping(string => uint256) providerIds; // +1
  uint256 nextProvider;
  mapping(uint256 => ProviderInfo) providers;

  IAssetStoreEx public immutable assetStore;

  constructor(IAssetStoreEx _assetStore) {
    assetStore = _assetStore;
  }

  function registerProvider(ProviderInfo memory _providerInfo) external override returns(uint256 providerId) {
    require(providerIds[_providerInfo.name]==0, "AssetCompooser:registerProvider, already registered");
    providers[nextProvider++] = _providerInfo;
    providerIds[_providerInfo.name] = nextProvider; // @notive: providerID + 1
    providerId = nextProvider - 1; 
    emit ProviderRegistered(msg.sender, providerId);
  }

  function providerCount() external view override returns(uint256) {
    return nextProvider;
  }

  function getProvider(uint256 _providerId) external view override returns(ProviderInfo memory) {
    return providers[_providerId];
  }

  function getProviderIndex(string memory _name) external view override returns(uint256) {
    uint256 idPlusOne = providerIds[_name];
    require(idPlusOne > 0, "AssestComposer:getProviderIndex, the provider does not exist");
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

contract AssetComposer is AssetComposerAdmin, IAssetComposer {
  using Strings for uint256;

  uint256 public nextId;
  mapping(uint256 => uint256[]) internal assets; // compositeId => [assetIds]
  mapping(uint256 => mapping(uint256 => bytes)) internal transforms;
  mapping(uint256 => mapping(uint256 => bytes)) internal fills;

  constructor(IAssetStoreEx _assetStore) AssetComposerAdmin(_assetStore) {
  }

  /**
    * @notice register a new composition by specifying asset layers.
    */
  function registerComposition(AssetLayer[] memory _layers) external override returns(uint256) {
    IStringValidator validator = assetStore.getStringValidator();
    uint256 compositionId = nextId++;
    uint256 assetCount = assetStore.getAssetCount();
    uint256 i;

    uint256[] memory assetIds = new uint256[](_layers.length);
    for (i=0; i<_layers.length; i++) {
      AssetLayer memory info = _layers[i];
      uint256 assetId = info.assetId;
      if (info.isComposition) {
        require(assetId < nextId, "register: Invalid compositionId");
        assetId *= 2; // @notice
      } else {
        // @notice assetId is 1-based (that's why <=, not <)
        require(assetId <= assetCount, "register: Invalid assetId");
        assetId = assetId * 2 + 1; // @notice
      }
      assetIds[i] = assetId;
      bytes memory transform = bytes(info.transform);
      if (transform.length > 0) {
        require(validator.validate(transform), "register: Invalid transform");
        transforms[compositionId][assetId] = transform;
      }
      bytes memory fill = bytes(info.fill);
      if (fill.length > 0) {
        require(validator.validate(fill), "register: Invalid fill");
        fills[compositionId][assetId] = fill;
      }
    }
    assets[compositionId] = assetIds;
    emit CompositionRegistered(msg.sender, compositionId);
    return compositionId;
  }

  /**
    * @notice returns the number of registered compositions.
    */
  function getCompositionCount() external view override returns(uint256) {
    return nextId;
  }

  /**
    * @notice returns a SVG part (and the tag) that represents the specified composition.
    */
  function generateSVGPart(uint256 _compositionId) public view override enabled(_compositionId) returns(string memory, string memory) {
    uint256[] memory assetIds = assets[_compositionId];
    uint256 i;
    bytes memory defs;
    bytes memory uses;
    string memory svgPart;
    string memory tagId;
    for (i=0; i < assetIds.length; i++) {
      uint256 assetId = assetIds[i];
      if (assetId % 2 == 0) {
        (svgPart, tagId) = generateSVGPart(assetId/2);
      } else {
        IAssetStore.AssetAttributes memory attr = assetStore.getAttributes(assetId/2);
        tagId = attr.tag;
        svgPart = assetStore.generateSVGPart(assetId/2, tagId);
      }
      defs = abi.encodePacked(defs, svgPart);
      uses = abi.encodePacked(uses, ' <use href="#', tagId, '"');
      bytes memory transform = transforms[_compositionId][assetId];
      if (transform.length > 0) {
        uses = abi.encodePacked(uses, ' transform="', transform, '"');
      }
      bytes memory fill = fills[_compositionId][assetId];
      if (fill.length > 0) {
        uses = abi.encodePacked(uses, ' fill="', fill, '"');
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
}
