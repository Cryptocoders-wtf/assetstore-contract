// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

/**
 * IAssetProvider is the interface each asset provider implements.
 * We assume there are three types of asset providers.
 * 1. Static asset provider, which has a collection of assets in the storage and returns them.
 * 2. Generative provider, which dynamically (but deterministically) generate assets.
 * 3. Data visualizer, which generates assets based on various data on the blockchain.
 */
interface IAssetProvider {
  struct ProviderInfo {
    string key;  // short and unique identifier of this provider (e.g., "asset")
    string name; // human readable display name (e.g., "Asset Store")
    IAssetProvider provider;
  }
  function getProviderInfo() external view returns(ProviderInfo memory);
  /**
   * This function returns SVGPart and the tag. SVGPart consists of one or more SVG elements.
   * The tag specifies the identifier of the SVG element to be displayed (using <use> tag).
   * The tag is the combination of the provider key and assetId (e.e., "asset123")
   */
  function generateSVGPart(uint256 _assetId) external view returns(string memory, string memory);
  /**
   * This function returns the number of assets available from this provider. 
   * If the total supply is 100, assetIds of available assets are 0,1,...99.
   * The generative providers may returns 0, which indicates the provider dynamically but
   * deterministically generates assets using the given assetId as the random seed (deterministic).
   */
  function totalSupply() external view returns(uint256);
}

/**
 * IAssetProviderRegistry is the interface implemented by AssetCompoer, which allows developers
 * of various asset providers to register those providers to AssetComposer. 
 */
interface IAssetProviderRegistry {
  event ProviderRegistered(address from, uint256 _providerId);
  function registerProvider(IAssetProvider _provider) external returns(uint256);
  function providerCount() external view returns(uint256);
  function getProvider(uint256 _providerId) external view returns(IAssetProvider.ProviderInfo memory);
  function getProviderId(string memory _key) external view returns(uint256);
}

/**
 * IAssetStore is the inteface AsseCompoer implements which allows developers to create
 * compositions with assets provided by registered asset providers.
 */
interface IAssetComposer {
  /**
   * AssetLayer represents a layer of a composition. 
   */
  struct AssetLayer {
    uint256 assetId; // assetId
    string provider; // provider key   
    string fill; // optional fill color
    string transform; // optinal transform
  }

  event CompositionRegistered(address from, uint256 compositionId);
  function registerComposition(AssetLayer[] memory _layers) external returns(uint256);
  function generateSVGPart(uint256 _compositionId) external view returns(string memory, string memory);
}