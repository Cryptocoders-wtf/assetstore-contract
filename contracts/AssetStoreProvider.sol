// SPDX-License-Identifier: MIT

/*
 * AssetComposer allows developers to create a composition from a collection of
 * assets (in AssetStore) and compositions.
 *
 * Created by Satoshi Nakajima (@snakajima)
 */

pragma solidity ^0.8.6;

import { IAssetStore, IAssetStoreEx } from './interfaces/IAssetStore.sol';
import { IAssetProvider } from './interfaces/IAssetComposer.sol';
import "@openzeppelin/contracts/utils/Strings.sol";

// IAssetProvider wrapper of AssetStore
contract AssetStoreProvider is IAssetProvider {
  IAssetStoreEx public immutable assetStore;

  constructor(IAssetStoreEx _assetStore) {
    assetStore = _assetStore;
  }

  function generateSVGPart(uint256 _assetId) external view override returns(string memory svgPart, string memory tag) {
    IAssetStore.AssetAttributes memory attr = assetStore.getAttributes(_assetId + 1);
    tag = attr.tag;
    svgPart = assetStore.generateSVGPart(_assetId + 1, tag);
  }

  function totalSupply() external view override returns(uint256) {
    return assetStore.getAssetCount();
  }
}
