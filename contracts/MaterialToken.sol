// SPDX-License-Identifier: MIT

/*
 * Material Icon NFT (ERC721). The mint function takes IAssetStore.AssetInfo as a parameter.
 * It registers the specified asset to the AssetStore and mint a token which represents
 * the "uplaoder" of the asset (who paid the gas fee). After that, the asset will beome
 * available to other smart contracts either as CC0 or CC-BY (see the AssetStore for details).
 * 
 * Created by Satoshi Nakajima (@snakajima)
 */

pragma solidity ^0.8.6;

import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "erc721a/contracts/ERC721A.sol";
import { IAssetStoreRegistry, IAssetStore } from './interfaces/IAssetStore.sol';
import { Base64 } from 'base64-sol/base64.sol';
import "@openzeppelin/contracts/utils/Strings.sol";
import { IProxyRegistry } from './external/opensea/IProxyRegistry.sol';

contract MaterialToken is Ownable, ERC721A {
  using Strings for uint256;
  using Strings for uint16;

  IAssetStoreRegistry public immutable registry;
  IAssetStore public immutable assetStore;

  uint256 constant tokensPerAsset = 4;
  mapping(uint256 => uint256) assetIds; // tokenId / tokensPerAsset => assetId

  // description
  string public description = "This is one of effts to create (On-Chain Asset Store)[https://assetstore.wtf].";

  // developer address.
  address public developer;

  // OpenSea's Proxy Registry
  IProxyRegistry public immutable proxyRegistry;

  constructor(
    IAssetStoreRegistry _registry, 
    IAssetStore _assetStore,
    address _developer,
    IProxyRegistry _proxyRegistry
  ) ERC721A("Material Icons", "MATERIAL") {
    registry = _registry;
    assetStore = _assetStore;
    developer = _developer;
    proxyRegistry = _proxyRegistry;
  }

  function isSoulbound(uint256 _tokenId) internal pure returns(bool) {
    return _tokenId % tokensPerAsset == 0;
  }

  function mintWithAsset(IAssetStoreRegistry.AssetInfo memory _assetInfo, uint256 _affiliate) external {
    uint256 assetId = registry.registerAsset(_assetInfo);
    uint256 tokenId = _nextTokenId(); 

    assetIds[tokenId / tokensPerAsset] = assetId;
    _mint(msg.sender, tokensPerAsset - 1);

    // Specified affliate token must be one of soul-bound token and not owned by the minter.
    if (_affiliate > 0 && isSoulbound(_affiliate) && ownerOf(_affiliate) != msg.sender) {
      _mint(ownerOf(_affiliate), 1);
    } else if ((tokenId / tokensPerAsset) % 4 == 0) {
      // 1 in 24 tokens goes to the developer
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

  function getAssetId(uint256 _tokenId) external view returns(uint256) {
    require(_exists(_tokenId), 'MaterialToken.getAssetId: nonexistent token');
    return assetIds[_tokenId / tokensPerAsset];
  }

string constant SVGHeader = '<svg viewBox="0 0 1024 1024'
      '"  xmlns="http://www.w3.org/2000/svg">\n'
      '<defs>\n'
      ' <filter id="f1" x="0" y="0" width="200%" height="200%">\n'
      '  <feOffset result="offOut" in="SourceAlpha" dx="24" dy="32" />\n'
      '  <feGaussianBlur result="blurOut" in="offOut" stdDeviation="16" />\n'
      '  <feBlend in="SourceGraphic" in2="blurOut" mode="normal" />\n'
      ' </filter>\n'
      '<g id="base">\n'
      ' <rect x="0" y="0" width="512" height="512" fill="#4285F4" />\n'
      ' <rect x="0" y="512" width="512" height="512" fill="#34A853" />\n'
      ' <rect x="512" y="0" width="512" height="512" fill="#FBBC05" />\n'
      ' <rect x="512" y="512" width="512" height="512" fill="#EA4335"/>\n'
      '</g>';

  function generateSVG(uint256 _style, string memory svgPart, string memory _tag) public pure returns (string memory) {
    bytes memory assetTag = abi.encodePacked('#', _tag);
    bytes memory image = abi.encodePacked(
      SVGHeader,
      svgPart,
      '</defs>\n'
      '<g filter="url(#f1)">\n');
    if (_style == 0) {
      image = abi.encodePacked(image,
      ' <mask id="assetMask">\n'
      '  <use href="', assetTag, '" fill="white" />\n'
      ' </mask>\n'
      ' <use href="#base" mask="url(#assetMask)" />\n');
    } else if (_style < tokensPerAsset - 1) {
      image = abi.encodePacked(image,
      ' <use href="#base" />\n'
      ' <use href="', assetTag, '" fill="',(_style % 2 == 0) ? 'black':'white','" />\n');
    } else {
      image = abi.encodePacked(image,
      ' <mask id="assetMask" desc="Material Icons (Apache 2.0)/Social/Public">\n'
      '  <rect x="0" y="0" width="1024" height="1024" fill="white" />\n'
      '  <use href="', assetTag, '" fill="black" />\n'
      ' </mask>\n'
      ' <use href="#base" mask="url(#assetMask)" />\n');
    }
    return string(abi.encodePacked(image, '</g>\n</svg>'));
  }

  function _jsonEscaled(bytes memory value) internal pure returns(bytes memory) {
    bytes memory res;
    uint i;
    for (i=0; i<value.length; i++) {
      uint8 b = uint8(value[i]);
      // Skip control codes, backslash and double-quote
      if (b >= 0x20 && b != 92 && b != 34) {
        res = abi.encodePacked(res, b);
      }
    }
    return res;
  }

  function _generateTraits(uint256 _tokenId, IAssetStore.AssetAttributes memory _attr) internal pure returns (bytes memory) {
    return abi.encodePacked(
      '{'
        '"trait_type":"Soulbound",'
        '"value":"', isSoulbound(_tokenId) ? 'Yes':'No', '"' 
      '},{'
        '"trait_type":"Group",'
        '"value":"', _attr.group, '"' 
      '},{'
        '"trait_type":"Category",'
        '"value":"', _attr.category, '"' 
      '},{'
        '"trait_type":"Minter",'
        '"value":"', (bytes(_attr.minter).length > 0)?
              _jsonEscaled(bytes(_attr.minter)) : bytes('(anonymous)'), '"' 
      '}'
    );
  }

  /**
    * @notice A distinct Uniform Resource Identifier (URI) for a given asset.
    * @dev See {IERC721Metadata-tokenURI}.
    */
  function tokenURI(uint256 _tokenId) public view override returns (string memory) {
    require(_exists(_tokenId), 'MaterialToken.tokenURI: nonexistent token');
    uint256 assetId = assetIds[_tokenId / tokensPerAsset];
    IAssetStore.AssetAttributes memory attr = assetStore.getAttributes(assetId);
    string memory svgPart = assetStore.generateSVGPart(assetId);
    bytes memory image = bytes(generateSVG(_tokenId % tokensPerAsset, svgPart, attr.tag));

    return string(
      abi.encodePacked(
        'data:application/json;base64,',
        Base64.encode(
          bytes(
            abi.encodePacked(
              '{"name":"', attr.name, 
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
}
