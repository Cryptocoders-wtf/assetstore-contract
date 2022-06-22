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
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import { IAssetStore } from './interfaces/IAssetStore.sol';
import { Base64 } from 'base64-sol/base64.sol';
import "@openzeppelin/contracts/utils/Strings.sol";

contract MaterialToken is Ownable, ERC721Enumerable {
  using Strings for uint256;

  IAssetStore public immutable assetStore;

  mapping(uint256 => uint256) assetIds; // tokenId => assetId
  mapping(uint256 => bool) primaries;

  // description
  string public description = "Celebrating Pride Month 2022";

  // The internal token ID tracker
  uint256 private _currentTokenId;

  constructor(IAssetStore _assetStore) ERC721("Material Icons", "MATERIAL") {
    assetStore = _assetStore;
  }

  function _safeMintWithAssetId(address _target, uint256 _assetId, bool _primary) internal returns(uint256) {
    uint256 tokenId = _currentTokenId++;
    _mint(_target, tokenId);
    assetIds[tokenId] = _assetId;
    primaries[tokenId] = _primary;
    return tokenId;    
  }

  function mint(IAssetStore.AssetInfo memory _assetInfo) external returns(uint256) {
    uint256 assetId = assetStore.registerAsset(_assetInfo);
    uint256 tokenId = _safeMintWithAssetId(msg.sender, assetId, true);
    return tokenId;    
  }

  function getAssetId(uint256 _tokenId) external view returns(uint256) {
    require(_exists(_tokenId), 'MaterialToken.getAssetId: nonexistent token');
    return assetIds[_tokenId];
  }

  /**
    * @notice A distinct Uniform Resource Identifier (URI) for a given asset.
    * @dev See {IERC721Metadata-tokenURI}.
    */
  function tokenURI(uint256 tokenId) public view override returns (string memory) {
    require(_exists(tokenId), 'MaterialToken.tokenURI: nonexistent token');
    string memory stringId = tokenId.toString();
    string memory name = string(abi.encodePacked('Material Icon #', stringId));
    uint256 assetId = assetIds[tokenId];
    string memory image = Base64.encode(bytes(abi.encodePacked(
      '<svg viewBox="0 0 24 24"  xmlns="http://www.w3.org/2000/svg">\n',
      '<defs>\n',
      ' <filter id="f1" x="0" y="0" width="200%" height="200%">\n',
      '  <feOffset result="offOut" in="SourceAlpha" dx="0.6" dy="1.0" />\n',
      '  <feGaussianBlur result="blurOut" in="offOut" stdDeviation="0.4" />\n',
      '  <feBlend in="SourceGraphic" in2="blurOut" mode="normal" />\n',
      ' </filter>\n',
      ' <clipPath id="nw"><rect x="0" y="0" width="12" height="12" /></clipPath>\n',
      ' <clipPath id="sw"><rect x="0" y="12" width="12" height="12" /></clipPath>\n',
      ' <clipPath id="ne"><rect x="12" y="0" width="12" height="12" /></clipPath>\n',
      ' <clipPath id="se"><rect x="12" y="12" width="12" height="12" /></clipPath>\n',
      assetStore.generateSVGPart(assetId),
      '</defs>\n',
      abi.encodePacked(
      '<g filter="url(#f1)">\n',
      ' <use href="#asset', assetId.toString() ,'" fill="#4285F4" clip-path="url(#ne)" />',
      ' <use href="#asset', assetId.toString() ,'" fill="#34A853" clip-path="url(#se)" />',
      ' <use href="#asset', assetId.toString() ,'" fill="#FBBC05" clip-path="url(#sw)" />',
      ' <use href="#asset', assetId.toString() ,'" fill="#EA4335" clip-path="url(#nw)" />',
      '</g>\n'),
      '</svg>')));
    return string(
      abi.encodePacked(
        'data:application/json;base64,',
        Base64.encode(
          bytes(
            abi.encodePacked('{"name":"', name, '", "description":"', description, '", "image": "', 'data:image/svg+xml;base64,', image, '"}')
          )
        )
      )
    );
  }  
}