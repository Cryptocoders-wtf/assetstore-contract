// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import { IAssetProvider } from './IAssetProvider.sol';

/**
 * IAssetStore is the inteface AsseCompoer implements which allows developers to create
 * compositions with assets provided by registered asset providers.
 */
interface IAssetComposer {
  /**
   * AssetLayer represents a layer of a composition. 
   */
  struct AssetLayer {
    uint256 assetId;  // assetId
    string provider;  // provider key
    string fill;      // optional fill color
    string transform; // optinal transform
    uint256 stroke;   // optional stroke (width)
  }

  event CompositionRegistered(address from, uint256 compositionId);

  function registerComposition(AssetLayer[] memory _layers) external returns(uint256);
}