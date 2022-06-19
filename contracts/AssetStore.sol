// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.6;

import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';

contract AssetStore is Ownable {
  struct Asset {
    uint8 assetType;
    string body;
    string mask;
    string color;
  }

  mapping(uint256 => Asset) private assets;
  uint256 private nextAsset;

  constructor() {
  }

  function registerAsset(Asset memory asset) external returns(uint256) {
    assets[nextAsset++] = asset;
    return nextAsset-1;
  }

}
