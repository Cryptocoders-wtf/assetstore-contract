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

  mapping(uint256 => uint256) assetIds; // tokenId => assetId
  mapping(uint256 => bool) isSoulbound;

  // description
  string public description = "This is one of effts to create (On-Chain Asset Store)[https://assetstore.xyz].";

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

  function _safeMintWithAssetId(address _target, uint256 _assetId, bool _isSoulbound) internal {
    uint256 tokenId = _nextTokenId();
    isSoulbound[tokenId] = _isSoulbound;
    assetIds[tokenId] = _assetId;
    _mint(_target, 1);
  }

  function mintWithAsset(IAssetStoreRegistry.AssetInfo memory _assetInfo, uint256 _affiliate) external {
    uint256 assetId = registry.registerAsset(_assetInfo);
    _safeMintWithAssetId(msg.sender, assetId, true); // souldbound token
    _safeMintWithAssetId(msg.sender, assetId, false); // bonus token

    // Specified affliate token must be one of soul-bound token and not owned by the minter.
    if (_affiliate > 0 && isSoulbound[_affiliate] && ownerOf(_affiliate) != msg.sender) {
      _safeMintWithAssetId(ownerOf(_affiliate), assetId, false); // affiliate token
    } else if (_nextTokenId() % 10 == 2) {
      // 10% of non-affiliated case. 
      _safeMintWithAssetId(developer, assetId, false); // developer token
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
    return assetIds[_tokenId];
  }

  function _generateSVGHeader(IAssetStore.AssetAttributes memory _attr) internal pure returns (bytes memory) {
    return abi.encodePacked(
      '<svg viewBox="0 0 ', _attr.width.toString() ,' ', _attr.height.toString(),
       '"  xmlns="http://www.w3.org/2000/svg">\n'
      '<defs>\n'
      ' <filter id="f1" x="0" y="0" width="200%" height="200%">\n'
      '  <feOffset result="offOut" in="SourceAlpha" dx="24" dy="32" />\n'
      '  <feGaussianBlur result="blurOut" in="offOut" stdDeviation="16" />\n'
      '  <feBlend in="SourceGraphic" in2="blurOut" mode="normal" />\n'
      ' </filter>\n');
  }

  function _generateClipPath(IAssetStore.AssetAttributes memory _attr) internal pure returns (bytes memory) {
    string memory hw = (_attr.width / 2).toString();
    string memory hh = (_attr.height / 2).toString();
    return abi.encodePacked(
        abi.encodePacked(
        ' <clipPath id="nw"><rect x="0" y="0" width="', hw, '" height="', hh, '" /></clipPath>\n'
        ' <clipPath id="sw"><rect x="0" y="', hh, '" width="', hw, '" height="', hh, '" /></clipPath>\n'
        ), abi.encodePacked(
        ' <clipPath id="ne"><rect x="', hw, '" y="0" width="', hw, '" height="', hh, '" /></clipPath>\n'
        ' <clipPath id="se"><rect x="', hw, '" y="', hh, '" width="', hw, '" height="', hh, '" /></clipPath>\n'
        )
      );
  }

  function _generateSVG(uint256 _tokenId, uint256 _assetId, IAssetStore.AssetAttributes memory _attr) internal view returns (bytes memory) {
    bytes memory assetTag = abi.encodePacked('#', _attr.tag);
    bytes memory image = abi.encodePacked(
      _generateSVGHeader(_attr),
      _generateClipPath(_attr),
      assetStore.generateSVGPart(_assetId),
      '</defs>\n');
    if (isSoulbound[_tokenId]) {
      image = abi.encodePacked(image,
        '<g filter="url(#f1)">\n'
        ' <use href="', assetTag ,'" fill="#4285F4" clip-path="url(#ne)" />\n'
        ' <use href="', assetTag ,'" fill="#34A853" clip-path="url(#se)" />\n'
        ' <use href="', assetTag ,'" fill="#FBBC05" clip-path="url(#sw)" />\n'
        ' <use href="', assetTag ,'" fill="#EA4335" clip-path="url(#nw)" />\n');
    } else {
      image = abi.encodePacked(image,
        '<g filter="url(#f1)" transform="scale(0.5)">\n');
      string[4] memory colors = ["#4285F4", "#34A853", "#FBBC05", "#EA4335"]; 
      uint16 i;
      for (i=0; i<4; i++) {
        uint16 x = (i % 2) * _attr.width;
        uint16 y = (i / 2 % 2) * _attr.height;
        image = abi.encodePacked(image,
          ' <use href="', assetTag ,'" fill="', colors[(i + _tokenId) % 4], 
              '" x="', x.toString(), '" y="', y.toString(), '"/> \n');
      }
    }
    return abi.encodePacked(image, '</g>\n</svg>');
  }

  function _generateTraits(uint256 _tokenId, IAssetStore.AssetAttributes memory _attr) internal view returns (bytes memory) {
    return abi.encodePacked(
      '{'
        '"trait_type":"Soulbound",'
        '"value":"', isSoulbound[_tokenId] ? 'Yes':'No', '"' 
      '},{'
        '"trait_type":"Group",'
        '"value":"', _attr.group, '"' 
      '},{'
        '"trait_type":"Category",'
        '"value":"', _attr.category, '"' 
      '},{'
        '"trait_type":"Minter",'
        '"value":"', (bytes(_attr.minter).length > 0)?_attr.minter:'(anonymous)', '"' 
      '}'
    );
  }

  /**
    * @notice A distinct Uniform Resource Identifier (URI) for a given asset.
    * @dev See {IERC721Metadata-tokenURI}.
    */
  function tokenURI(uint256 _tokenId) public view override returns (string memory) {
    require(_exists(_tokenId), 'MaterialToken.tokenURI: nonexistent token');
    uint256 assetId = assetIds[_tokenId];
    IAssetStore.AssetAttributes memory attr = assetStore.getAttributes(assetId);
    bytes memory image = _generateSVG(_tokenId, assetId, attr);

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