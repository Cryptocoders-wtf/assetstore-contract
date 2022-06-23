// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.6;

// IAssetStore is the inteface for consumers of the AsseStore.
interface IAssetStore {
  // Browsing
  function getGroupCount() external view returns(uint32);
  function getGroupNameAtIndex(uint32 groupIndex) external view returns(string memory);
  function getCategoryCount(string memory group) external view returns(uint32);
  function getCategoryNameAtIndex(string memory group, uint32 categoryIndex) external view returns(string memory);
  function getAssetCountInCategory(string memory group, string memory category) external view returns(uint32);
  function getAssetIdInCategory(string memory group, string memory category, uint32 assetIndex) external view returns(uint256);
  function getAssetIdWithName(string memory group, string memory category, string memory name) external view returns(uint256);

  // Fetching
  function generateSVG(uint256 _assetId) external view returns(string memory);
  function generateSVGPart(uint256 _assetId) external view returns(string memory);
}

// IAssetStoreRegistry is the interface for contracts who registers assets to the AssetStore.
interface IAssetStoreRegistry {
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

  function registerAsset(AssetInfo memory _assetInfo) external returns(uint256);
  function registerAssets(AssetInfo[] memory _assetInfos) external returns(uint256);
}