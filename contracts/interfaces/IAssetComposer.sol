// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface IAssetProvider {
  function generateSVGPart(uint256 _assetId) external view returns(string memory, string memory);
  function totalSupply() external view returns(uint256);
}

interface IAssetProviderRegistry {
  struct ProviderInfo {
    string name;
    IAssetProvider provider;
  }
  event ProviderRegistered(address from, uint256 _providerId);
  function registerProvider(ProviderInfo memory _providerInfo) external returns(uint256);
  function providerCount() external view returns(uint256);
  function getProvider(uint256 _providerId) external view returns(ProviderInfo memory);
  function getProviderIndex(string memory _name) external view returns(uint256);
}

// IAssetStore is the inteface for consumers of the AsseCompoer.
interface IAssetComposer {
  struct AssetLayer {
    uint256 assetId; // either compositeId or assetId
    bool isComposition;
    //string provider; // provider name   
    string fill; // optional fill color
    string transform; // optinal transform
  }

  event CompositionRegistered(address from, uint256 compositionId);
  function registerComposition(AssetLayer[] memory _infos) external returns(uint256);
  function generateSVGPart(uint256 _assetId) external view returns(string memory, string memory);
}