// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import { IAssetProvider } from './IAssetProvider.sol';

/**
 * IAssetProviderRegistry is the interface implemented by AssetCompoer, which allows developers
 * of asset providers to register those providers to AssetComposer.
 */
interface IAssetProviderRegistry {
  event ProviderRegistered(address from, uint256 _providerId);
  event ProviderUpdated(address from, uint256 _providerId);

  /**
   * This function registers the specified provider to the provider registry.
   * It is possible to update it using the same key, but the owner of the new provider
   * must match the previous owner.
   */
  function registerProvider(IAssetProvider _provider) external returns(uint256);
  function providerCount() external view returns(uint256);
  function getProvider(uint256 _providerId) external view returns(IAssetProvider.ProviderInfo memory, bool);
  function getProviderId(string memory _key) external view returns(uint256);
}