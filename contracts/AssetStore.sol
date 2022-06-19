// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.6;

import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';

contract AssetStore is Ownable {
  struct Part {
    string body;
    string mask;
    string color;
  }

  struct Asset {
    uint256[] partsIndeces;
  }

  mapping(uint256 => Asset) private assets;
  uint256 private nextAsset;
  mapping(uint256 => Part) private parts;
  uint256 private nextPart;

  constructor() {
  }

  function _registerPart(Part memory _part) internal returns(uint256) {
    parts[nextPart++] = _part;
    return nextPart-1;    
  }

  function registerAsset(Part[] memory _parts) external returns(uint256) {
    uint size = _parts.length;
    uint256[] memory indeces = new uint256[](size);
    uint i;
    for (i=0; i<size; i++) {
      indeces[i] = _registerPart(_parts[i]);
    }
    Asset memory asset;
    asset.partsIndeces = indeces;
    assets[nextAsset++] = asset;
    return nextAsset-1;
  }

  function getAssetCount() external view returns(uint256) {
    return nextAsset;
  }

  function getAsset(uint256 _assetIndex) external view returns(Asset memory) {
    return assets[_assetIndex];
  }
}
