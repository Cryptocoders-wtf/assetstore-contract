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
    string name;
    uint256[] partsIndeces;
  }

  struct AssetInfo {
    string name;
    Part[] parts;
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

  function _safeRegisterAsset(AssetInfo memory _assetInfo) internal returns(uint256) {
    uint size = _assetInfo.parts.length;
    uint256[] memory indeces = new uint256[](size);
    uint i;
    for (i=0; i<size; i++) {
      indeces[i] = _registerPart(_assetInfo.parts[i]);
    }
    Asset memory asset;
    asset.name = _assetInfo.name;
    asset.partsIndeces = indeces;
    assets[nextAsset++] = asset;
    return nextAsset-1;
  }

  function registerAsset(AssetInfo memory _assetInfo) external onlyOwner returns(uint256) {
    return _safeRegisterAsset(_assetInfo);
  }

  function registerAssets(AssetInfo[] memory _assetInfos) external onlyOwner returns(uint256) {
    uint i;
    uint assetIndex;
    for (i=0; i<_assetInfos.length; i++) {
      assetIndex = _safeRegisterAsset(_assetInfos[i]);
    }
    return assetIndex;
  }

  function _generateSVGAsset(uint256 _assetIndex) internal view returns(bytes memory) {
    Asset storage asset = assets[_assetIndex];
    uint256[] storage indeces = asset.partsIndeces;
    bytes memory pack = abi.encodePacked('<g desc="', asset.name, '">\n');
    uint i;
    for (i=0; i<indeces.length; i++) {
      Part memory part = parts[indeces[i]];
      pack = abi.encodePacked(pack, ' <path d="', part.body, '" fill="', part.color ,'" />\n');
    }
    pack = abi.encodePacked(pack, '</g>\n');
    return pack;
  }

  function generateSVG(uint256 _assetIndex) external view returns(string memory) {
    require(_assetIndex < nextAsset, "asset index is out of range"); 
    bytes memory pack = abi.encodePacked('<svg viewBox="0 0 24 24"  xmlns="http://www.w3.org/2000/svg">', 
      _generateSVGAsset(_assetIndex), 
      '</svg>');
    return string(pack);
  }

  function getAssetCount() external view returns(uint256) {
    return nextAsset;
  }

  function getAsset(uint256 _assetIndex) external view onlyOwner returns(Asset memory) {
    return assets[_assetIndex];
  }

  function getPart(uint256 _partIndex) external view onlyOwner returns(Part memory) {
    return parts[_partIndex];
  }

}
