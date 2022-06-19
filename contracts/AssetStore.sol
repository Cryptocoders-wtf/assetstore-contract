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
    uint32 groupId; // index to groups + 1
    string category;
    string name;
    uint256[] partsIndeces;
  }

  struct AssetInfo {
    string group;
    string category;
    string name;
    Part[] parts;
  }

  mapping(uint256 => Asset) private assets;
  uint256 private nextAsset;
  mapping(uint256 => Part) private parts;
  uint256 private nextPart;
  mapping(uint32 => string) private groups;
  uint32 private nextGroup; 
  mapping(string => uint32) private groupIds; // index+1

  constructor() {
  }

  function _getGroupId(string memory group) internal returns(uint32) {
    uint32 groupId = groupIds[group];
    if (groupId == 0) {
      groups[nextGroup++] = group;
      groupId = nextGroup; // idex + 1
      groupIds[group] = groupId; 
    }
    return groupId;
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
    uint256 assetId = nextAsset++;
    Asset memory asset;
    asset.name = _assetInfo.name;
    asset.groupId = _getGroupId(_assetInfo.group);
    asset.category = _assetInfo.category;
    asset.partsIndeces = indeces;
    assets[assetId] = asset;
    return assetId;
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

  function _getDescription(Asset storage asset) internal view returns(bytes memory) {
    return abi.encodePacked(groups[asset.groupId - 1], '/', asset.category, '/', asset.name);
  }

  function _generateSVGAsset(uint256 _assetIndex) internal view returns(bytes memory) {
    Asset storage asset = assets[_assetIndex];
    uint256[] storage indeces = asset.partsIndeces;
    bytes memory pack = abi.encodePacked(' <g desc="', _getDescription(asset), '">\n');
    uint i;
    for (i=0; i<indeces.length; i++) {
      Part memory part = parts[indeces[i]];
      pack = abi.encodePacked(pack, '  <path d="', part.body, '" fill="', part.color ,'" />\n');
    }
    pack = abi.encodePacked(pack, ' </g>\n');
    return pack;
  }

  function generateSVG(uint256 _assetIndex) external view returns(string memory) {
    require(_assetIndex < nextAsset, "asset index is out of range"); 
    bytes memory pack = abi.encodePacked(
      '<svg viewBox="0 0 24 24"  xmlns="http://www.w3.org/2000/svg">\n', 
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
