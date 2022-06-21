// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.6;

interface IAssetStore {
  function getAssetIdWithName(string memory group, string memory category, string memory name) external view returns(uint256);
  function generateSVG(uint256 _assetId) external view returns(string memory);
}