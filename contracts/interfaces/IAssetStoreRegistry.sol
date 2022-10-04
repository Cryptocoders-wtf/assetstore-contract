// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

// IAssetStoreRegistry is the interface for contracts who registers assets to the AssetStore.
interface IAssetStoreRegistry {
  struct Part {
    bytes body;
    string color;
  }

  struct AssetInfo {
    string group;
    string category;
    string name;
    string minter; // the name of the minter, who is paying the gas fee
    address soulbound; // wallet address of the minter
    bytes metadata; // group/category specific metadata (optional)
    Part[] parts;
  }

  event AssetRegistered(address from, uint256 assetId);
  event GroupAdded(string group);
  event CategoryAdded(string group, string category);

  function registerAsset(AssetInfo memory _assetInfo) external returns(uint256);
  function registerAssets(AssetInfo[] memory _assetInfos) external;
}