// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.6;

interface IAssetStore {
  struct Part {
    string body;
    string mask;
    string color;
  }

  struct AssetInfo {
    string group;
    string category;
    string name;
    uint16 width;
    uint16 height;
    Part[] parts;
  }

  // Public functions
  function getAssetIdWithName(string memory group, string memory category, string memory name) external view returns(uint256);
  function generateSVG(uint256 _assetId) external view returns(string memory);
  function generateSVGPart(uint256 _assetId) external view returns(string memory);

  // Private functions
  function registerAsset(AssetInfo memory _assetInfo) external returns(uint256);
  function registerAssets(AssetInfo[] memory _assetInfos) external returns(uint256);
}