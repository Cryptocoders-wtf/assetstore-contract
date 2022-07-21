// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import { IAssetStore } from '../interfaces/IAssetStore.sol';

contract Benchmark {
  IAssetStore assetStore;
  uint256 counter;

  constructor(IAssetStore _assetStore) {
    assetStore = _assetStore;
    counter += 1;
  }

  function measure(uint256 _assetId) external returns(string memory) {
    counter += 1;
    return assetStore.generateSVG(_assetId);
  }
}