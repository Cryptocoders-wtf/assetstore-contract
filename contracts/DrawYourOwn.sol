// SPDX-License-Identifier: MIT

/*
 * Kamon NFT (ERC721). The mint function takes IAssetStore.AssetInfo as a parameter.
 * It registers the specified asset to the AssetStore and mint a token which represents
 * the "minter" of the asset (who paid the gas fee), along with two additional bonus tokens.
 * 
 * It uses ERC721A as the base contract, which is quite efficent to mint multiple tokens
 * with a single transaction. 
 *
 * Once minted, the asset will beome available to other smart contract developers,
 * for free, either CC0, CC-BY-SA(Attribution-ShareAlike), Appache, MIT or similar.
 * 
 * Created by Satoshi Nakajima (@snakajima)
 */

pragma solidity ^0.8.6;

import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "erc721a/contracts/ERC721A.sol";
import { IAssetStoreRegistry, IAssetStore, IAssetStoreEx } from './interfaces/IAssetStore.sol';
import { IAssetStoreToken } from './interfaces/IAssetStoreToken.sol';
import { Base64 } from 'base64-sol/base64.sol';
import "@openzeppelin/contracts/utils/Strings.sol";
import { IProxyRegistry } from './external/opensea/IProxyRegistry.sol';
import { IAssetComposer, IAssetProviderRegistry } from './interfaces/IAssetComposer.sol';

import "./AssetComposer.sol";
import "./AssetStoreProvider.sol";

abstract contract DrawYourOwnCore is ERC721A {
  IAssetStoreRegistry public immutable registry;
  IAssetStoreEx public immutable assetStore;

  mapping(uint256 => uint256) public remixBase; // tokenId => base tokenId
  mapping(uint256 => uint256) public totalEarned; // wei 

  uint256 constant _tokensPerAsset = 4;
  mapping(uint256 => uint256) assetIds; // tokenId / _tokensPerAsset => assetId (*2+1) or compositionId (*2)
  mapping(uint256 => uint256) uploadedAssetIds; // tokenId / _tokenPerAsset => assetId of uploaded asset

  // description
  string public description = "This is one of effts to create (On-Chain Asset Store)[https://assetstore.wtf/draw]. ";

  // developer address.
  address public developer;

  // OpenSea's Proxy Registry
  IProxyRegistry public immutable proxyRegistry;

  AssetComposer public immutable assetComposer;

  /*
   * @notice both _registry and _assetStore points to the AssetStore.
   */
  constructor(
    IAssetStoreRegistry _registry, 
    IAssetStoreEx _assetStore,
    address _developer,
    IProxyRegistry _proxyRegistry
  ) ERC721A("Draw Your Own NFT", "DrawNFT") {
    registry = _registry;
    assetStore = _assetStore;
    developer = _developer;
    proxyRegistry = _proxyRegistry;

    AssetComposer composer = new AssetComposer(_assetStore);
    composer.transferOwnership(msg.sender);
    IAssetProvider assetProvider = new AssetStoreProvider(_assetStore);
    composer.registerProvider(assetProvider);
    composer.registerProvider(composer);

    assetComposer = composer;
  }

  function _isPrimary(uint256 _tokenId) internal pure returns(bool) {
    return _tokenId % _tokensPerAsset == 0;
  }
}

abstract contract DrawYourOwnAdmin is DrawYourOwnCore, Ownable {
  // 1e18 = 1 ether
  uint256 public mintPrice = 2e16; //0.02 ether 

  function withdraw() external onlyOwner {
      address payable payableTo = payable(owner());
      payableTo.transfer(address(this).balance);
  }

  function setMintPrice(uint256 _price) external onlyOwner {
    mintPrice = _price;
  }

  function setDescription(string memory _description) external onlyOwner {
      description = _description;
  }
}

/*
abstract contract DrawYourOwnPayout is DrawYourOwnAdmin {
  function transferPayout(uint256 _tokenId, uint256 _amount) internal {
    address payable payableTo = payable(ownerOf(_tokenId));
    payableTo.transfer(_amount);
    totalEarned[_tokenId] += _amount;
    emit PayedOut(payableTo, _tokenId, _amount);    
  }

  function processPayout(uint256 _tokenId, uint256 _payout) internal {
    uint256 baseTokenId = remixBase[_tokenId]; // 1-based
    if (baseTokenId > 0) {
      uint256 thisPayout = _payout * 20 / 100; // 20%
      transferPayout(_tokenId, thisPayout);
      processPayout(baseTokenId - 1, _payout - thisPayout);
    } else {
      transferPayout(_tokenId, _payout);
    }
  }
}
*/

contract DrawYourOwn is DrawYourOwnAdmin, IAssetStoreToken {
  using Strings for uint256;
  using Strings for uint16;

  constructor(
    IAssetStoreRegistry _registry, 
    IAssetStoreEx _assetStore,
    address _developer,
    IProxyRegistry _proxyRegistry
  ) DrawYourOwnCore(_registry, _assetStore, _developer, _proxyRegistry) {}

  struct RemixInfo {
    uint256 tokenId; // tokenId (of this NFT)
    string fill; // optional fill color
    string transform; // optinal transform
  }

  /**
   * It registers the specified asset to the AssetStore and mint three tokens to the msg.sender, 
   * and one additional token to either the affiliator, the developer or the owner.
   * _remixes specifies the remix tokens (optional). 
   * _layers specifies overlay assets (optional). 
   */
  function mintWithAsset(IAssetStoreRegistry.AssetInfo memory _assetInfo, uint256 _affiliate, RemixInfo[] memory _remixes, IAssetComposer.AssetLayer[] memory _overlays) external payable {
    uint256 tokenId = _nextTokenId();
    _assetInfo.group = "Draw Your Own";
    _assetInfo.name = string(abi.encodePacked("Drawing ", tokenId.toString()));
    uint256 assetId = registry.registerAsset(_assetInfo);
    uploadedAssetIds[tokenId / _tokensPerAsset] = assetId;

    // @notice
    if (_remixes.length == 0 && _overlays.length == 0) {
      assetIds[tokenId / _tokensPerAsset] = assetId * 2 + 1; // @notice
    } else {
      uint256 i;
      uint256 offset = _remixes.length;
      if (offset + _overlays.length > 0) {
        require(msg.value >= mintPrice, 'Must send the mint price');
      }
      IAssetComposer.AssetLayer[] memory layers = new IAssetComposer.AssetLayer[](offset + 1 + _overlays.length);
      for (i = 0; i < _remixes.length; i++) {
        RemixInfo memory remix = _remixes[i];
        if (i == 0) {
          // We store only the primary remix tokenId
          remixBase[tokenId] = remix.tokenId + 1; // 1-based
        }

        uint256 remixAssetId = assetIdOfToken(remix.tokenId);
        if (remixAssetId % 2 ==0) {
          layers[i].assetId = remixAssetId / 2;
          layers[i].provider = "comp";
        } else {
          layers[i].assetId = remixAssetId / 2 - 1; // Switch it to 0-based
          layers[i].provider = "asset";
        }
        layers[i].fill = remix.fill; // optional color
        layers[i].transform = remix.transform; // optional transform
      }
      layers[offset].assetId = assetId - 1; // Switch it to 0-based
      layers[offset].provider = "asset";
      for (i = 0; i < _overlays.length; i++) {
        layers[offset + 1 + i] = _overlays[i];
      }      
      uint256 compositionId = assetComposer.registerComposition(layers);
      assetComposer.processPayout{value:(msg.value * 975) / 1000}(compositionId, offset);
      assetIds[tokenId / _tokensPerAsset] = compositionId * 2; // @notice
    }

    _mint(msg.sender, _tokensPerAsset - 1);

    // Specified affliate token must be one of the primary tokens and not owned by the minter.
    if (_affiliate > 0 && _isPrimary(_affiliate) && ownerOf(_affiliate) != msg.sender) {
      _mint(ownerOf(_affiliate), 1);
    } else if ((tokenId / _tokensPerAsset) % 4 == 0) {
      // 1 in 16 tokens of non-affiliated mints go to the developer
      _mint(developer, 1);
    } else {
      // the rest goes to the owner for distribution
      _mint(owner(), 1);
    }
  }
  /*
   * @notice get next tokenId.
   */
  function getCurrentToken() external view returns (uint256) {                  
    return _nextTokenId();
  }

  /**
    * @notice Override isApprovedForAll to whitelist user's OpenSea proxy accounts to enable gas-less listings.
    */
  function isApprovedForAll(address owner, address operator) public view override returns (bool) {
      // Whitelist OpenSea proxy contract for easy trading.
      if (proxyRegistry.proxies(owner) == operator) {
          return true;
      }
      return super.isApprovedForAll(owner, operator);
  }

  string constant SVGHeader = '<svg viewBox="0 0 1024 1024'
      '"  xmlns="http://www.w3.org/2000/svg">\n'
      '<defs>\n';

  /*
   * A function of IAssetStoreToken interface.
   * It generates SVG with the specified style, using the given "SVG Part".
   */
  function generateSVG(string memory _svgPart, uint256 _style, string memory _tag) public pure override returns (string memory) {
    // Constants of non-value type not yet implemented by Solidity
    string[4] memory backColors = [
      "", "url(#silver)", "url(#gold)", "" 
    ];

    uint index = _style % _tokensPerAsset;
    bytes memory image = abi.encodePacked(
      SVGHeader,
      _svgPart);
    if (index == 1) {
      image = abi.encodePacked(
        image, 
        '<linearGradient id="silver" x1="0.2" x2="0" y1="0" y2="1">\n'
        '  <stop offset="0%" stop-color="#80807F"/>\n'
        ' <stop offset="50%" stop-color="#EEF0F2" />\n'
        ' <stop offset="100%" stop-color="#80807F"/>\n'
        '</linearGradient>\n');
    } else if (index == 2) {
      image = abi.encodePacked(
        image, 
        '<linearGradient id="gold" x1="0.2" x2="0" y1="0" y2="1">\n'
        '  <stop offset="0%" stop-color="#CCAB09"/>\n'
        ' <stop offset="50%" stop-color="#FFF186" />\n'
        ' <stop offset="100%" stop-color="#CCAB09"/>\n'
        '</linearGradient>\n');
    } else if (index == 3) {
      image = abi.encodePacked(
        image, 
      ' <filter id="f1" x="0" y="0" width="200%" height="200%">\n'
      '  <feOffset result="offOut" in="SourceAlpha" dx="24" dy="32" />\n'
      '  <feGaussianBlur result="blurOut" in="offOut" stdDeviation="16" />\n'
      '  <feBlend in="SourceGraphic" in2="blurOut" mode="normal" />\n'
      ' </filter>\n');
    }
    image =  abi.encodePacked(image, '</defs>\n');
    if (bytes(backColors[index]).length > 0) {
      image =  abi.encodePacked(image,
        ' <rect x="0" y="0" width="100%" height="100%" fill="',backColors[index],'" />\n');
    }
    if (index == 3) {
      image =  abi.encodePacked(image,
        ' <use filter="url(#f1)" href="#', _tag, '" />\n');
    } else {
      image =  abi.encodePacked(image,
        ' <use href="#', _tag, '" />\n');
    }
    image =  abi.encodePacked(image, '</svg>\n');
    return string(image);
  }

  /*
   * A function of IAssetStoreToken interface.
   * It returns the assetId, which this token uses.
   */
  function assetIdOfToken(uint256 _tokenId) public view override returns(uint256) {
    require(_exists(_tokenId), 'CustomToken.assetIdOfToken: nonexistent token');
    return assetIds[_tokenId / _tokensPerAsset];
  }

  /*
   * A function of IAssetStoreToken interface.
   * Each 16-bit represents the number of possible styles, allowing various combinations.
   */
  function styles() external pure override returns(uint256) {
    // We just return the number of tokens per asset in lowest 16-bit.
    return _tokensPerAsset;
  }

  function _generateTraits(uint256 _tokenId, IAssetStore.AssetAttributes memory _attr) internal view returns (bytes memory) {
    bytes memory pack = abi.encodePacked(
      '{'
        '"trait_type":"Primary",'
        '"value":"', _isPrimary(_tokenId) ? 'Yes':'No', '"' 
      '},{'
        '"trait_type":"Group",'
        '"value":"', _attr.group, '"' 
      '},{'
        '"trait_type":"Category",'
        '"value":"', _attr.category, '"' 
      '},{'
        '"trait_type":"Name",'
        '"value":"', _attr.name, '"');
    pack = abi.encodePacked(pack,  
      '},{'
        '"trait_type":"Minter",'
        '"value":"', (bytes(_attr.minter).length > 0)?
              assetStore.getStringValidator().sanitizeJason(_attr.minter) : bytes('(anonymous)'), '"' 
      '},{'
        '"trait_type":"Remix",'
        '"value":"', remixBase[_tokenId] > 0 ? (remixBase[_tokenId] - 1).toString() : "(none)", '"' 
      '},{'
        '"trait_type":"Earned",'
        '"value":"', (totalEarned[_tokenId] / 1e9).toString(), 'Gwei"' 
      '}'
    );
    return pack;
  }

  function generateSVGPart(uint256 _tokenId) public view returns(string memory, string memory) {
    uint256 assetId = assetIdOfToken(_tokenId);
    if (assetId % 2 == 0) {
      return assetComposer.generateSVGPart(assetId / 2);
    }

    IAssetStore.AssetAttributes memory attr = assetStore.getAttributes(assetId / 2);
    string memory svgPart = assetStore.generateSVGPart(assetId / 2, attr.tag);
    return (svgPart, attr.tag);
  }

  /**
    * @notice A distinct Uniform Resource Identifier (URI) for a given asset.
    * @dev See {IERC721Metadata-tokenURI}.
    */
  function tokenURI(uint256 _tokenId) public view override returns (string memory) {
    require(_exists(_tokenId), 'CustomToken.tokenURI: nonexistent token');
    (string memory svgPart, string memory tag) = generateSVGPart(_tokenId);
    bytes memory image = bytes(generateSVG(svgPart, _tokenId % _tokensPerAsset, tag));

    uint256 uploadedAssetId = uploadedAssetIds[_tokenId / _tokensPerAsset];
    IAssetStore.AssetAttributes memory attr = assetStore.getAttributes(uploadedAssetId);

    return string(
      abi.encodePacked(
        'data:application/json;base64,',
        Base64.encode(
          bytes(
            abi.encodePacked(
              '{"name":"Drawing ', _tokenId.toString(), 
                '","description":"', description, 
                '","attributes":[', _generateTraits(_tokenId, attr), 
                '],"image":"data:image/svg+xml;base64,', 
                Base64.encode(image), 
              '"}')
          )
        )
      )
    );
  }  

  function tokensPerAsset() public pure returns(uint256) {
    return _tokensPerAsset;
  }
}
