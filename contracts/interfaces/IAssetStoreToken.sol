// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface IAssetStoreToken {
  function generateSVG(string memory _svgPart, uint256 _style, string memory _tag) external returns (string memory);
  function assetIdOfToken(uint256 _tokenId) external returns(uint256);
  function styles() external returns(uint256);
}