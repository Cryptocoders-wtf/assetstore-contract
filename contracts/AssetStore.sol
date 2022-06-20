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
    uint32 categoryId;
    string name;
    uint256[] partsIndeces;
  }

  struct AssetInfo {
    string group;
    string category;
    string name;
    Part[] parts;
  }

  // asset & part database
  mapping(uint256 => Asset) private assets;
  uint256 private nextAssetIndex = 1; // 0 indicates an error
  mapping(uint256 => Part) private parts;
  uint256 private nextPartIndex = 1; // 0 indicates an error

  // Groups (for browsing)
  mapping(uint32 => string) private groups;
  uint32 private nextGroup; 
  mapping(string => uint32) private groupIds; // index+1

  // Grouped categories (for browsing)
  mapping(string => mapping(uint32 => string)) categories;
  mapping(string => uint32) nextCategoryIndeces;
  mapping(string => mapping(string => uint32)) private categoryIds; // index+1

  // Grouped and categorized assetIds (for browsing)
  mapping(string => mapping(string => mapping(uint32 => uint256))) private assetIdsInCategory;
  mapping(string => mapping(string => uint32)) private nextAssetIndecesInCategory;

  // Group/Category/Name => assetId
  mapping(string => mapping(string => mapping(string => uint256))) private assetIdsLookup;

  constructor() {
  }

  // Returns the groupId of the specified group, creating a new Id if necessary.
  // @notice gruopId == groupIndex + 1
  function _getGroupId(string memory group) internal returns(uint32) {
    uint32 groupId = groupIds[group];
    if (groupId == 0) {
      groups[nextGroup++] = group;
      groupId = nextGroup; // idex + 1
      groupIds[group] = groupId; 
    }
    return groupId;
  }

  // Returns the categoryId of the specified category in a group, creating a new Id if necessary.
  // The categoryId is unique only within that group. 
  // @notice categoryId == categoryIndex + 1
  function _getCategoryId(string memory group, string memory category) internal returns(uint32) {
    uint32 categoryId = categoryIds[group][category];
    if (categoryId == 0) {
      categories[group][nextCategoryIndeces[group]++] = category;
      categoryId = nextCategoryIndeces[group]; // index + 1
      categoryIds[group][category] = categoryId;
    }
    return categoryId;
  }

  // Returns the number of registered groups.
  function getGroupCount() external view returns(uint32) {
    return nextGroup;
  }

  // Returns the name of a group specified with groupIndex. 
  function getGroupNameAtIndex(uint32 groupIndex) external view returns(string memory) {
    require(groupIndex < nextGroup, "The group index is out of range");
    return groups[groupIndex];
  }

  // Returns the number of categories in the specified group.
  function getCategoryCount(string memory group) external view returns(uint32) {
    return nextCategoryIndeces[group];
  }

  // Returns the name of category specified with group/categoryIndex pair.
  function getCategoryNameAtIndex(string memory group, uint32 categoryIndex) external view returns(string memory) {
    require(categoryIndex < nextCategoryIndeces[group], "The categoryIndex index is out of range");
    return categories[group][categoryIndex];
  }

  // Returns the number of asset in the specified group/category. 
  function getAssetCountInCategory(string memory group, string memory category) external view returns(uint32) {
    return nextAssetIndecesInCategory[group][category];
  }

  // Returns the assetId of the specified group/category/assetIndex. 
  function getAssetIdInCategory(string memory group, string memory category, uint32 assetIndex) external view returns(uint256) {
    require(assetIndex < nextAssetIndecesInCategory[group][category], "The assetIndex is out of range");
    return assetIdsInCategory[group][category][assetIndex];
  }

  // Returns the assetId of the specified group/category/name. 
  function getAssetIdWithName(string memory group, string memory category, string memory name) external view returns(uint256) {
    return assetIdsLookup[group][category][name];
  }

  function _registerPart(Part memory _part) internal returns(uint256) {
    parts[nextPartIndex++] = _part;
    return nextPartIndex-1;    
  }

  function _registerAsset(AssetInfo memory _assetInfo) internal returns(uint256) {
    require(assetIdsLookup[_assetInfo.group][_assetInfo.category][_assetInfo.name] == 0, "Asset already exists with the same group, category and name");
    uint size = _assetInfo.parts.length;
    uint256[] memory indeces = new uint256[](size);
    uint i;
    for (i=0; i<size; i++) {
      indeces[i] = _registerPart(_assetInfo.parts[i]);
    }
    uint256 assetId = nextAssetIndex++;
    Asset memory asset;
    asset.name = _assetInfo.name;
    asset.groupId = _getGroupId(_assetInfo.group);
    asset.categoryId = _getCategoryId(_assetInfo.group, _assetInfo.category);
    asset.partsIndeces = indeces;
    assets[assetId] = asset;
    assetIdsInCategory[_assetInfo.group][_assetInfo.category][nextAssetIndecesInCategory[_assetInfo.group][_assetInfo.category]++] = assetId;
    assetIdsLookup[_assetInfo.group][_assetInfo.category][_assetInfo.name] = assetId;

    return assetId;
  }

  function registerAsset(AssetInfo memory _assetInfo) external onlyOwner returns(uint256) {
    return _registerAsset(_assetInfo);
  }

  function registerAssets(AssetInfo[] memory _assetInfos) external onlyOwner returns(uint256) {
    uint i;
    uint assetIndex;
    for (i=0; i<_assetInfos.length; i++) {
      assetIndex = _registerAsset(_assetInfos[i]);
    }
    return assetIndex;
  }

  function _getDescription(Asset storage asset) internal view returns(bytes memory) {
    string memory group = groups[asset.groupId - 1];
    return abi.encodePacked(group, '/', categories[group][asset.categoryId - 1], '/', asset.name);
  }

  function _safeGenerateSVGPart(uint256 _assetId) internal view returns(bytes memory) {
    Asset storage asset = assets[_assetId];
    uint256[] storage indeces = asset.partsIndeces;
    bytes memory pack = abi.encodePacked(' <g desc="', _getDescription(asset), '">\n');
    uint i;
    for (i=0; i<indeces.length; i++) {
      Part memory part = parts[indeces[i]];
      if (bytes(part.color).length > 0) {
        pack = abi.encodePacked(pack, '  <path d="', part.body, '" fill="', part.color ,'" />\n');
      } else {
        pack = abi.encodePacked(pack, '  <path d="', part.body, '" />\n');
      }
    }
    pack = abi.encodePacked(pack, ' </g>\n');
    return pack;
  }

  // returns a SVG part with the specified assetId
  function generateSVGPart(uint256 _assetId) external view returns(string memory) {
    require(_assetId > 0 && _assetId < nextAssetIndex, "asset index is out of range"); 
    return string(_safeGenerateSVGPart(_assetId));
  }

  // returns a full SVG with the specified assetId
  function generateSVG(uint256 _assetId) external view returns(string memory) {
    require(_assetId > 0 && _assetId < nextAssetIndex, "asset index is out of range"); 
    bytes memory pack = abi.encodePacked(
      '<svg viewBox="0 0 24 24"  xmlns="http://www.w3.org/2000/svg">\n', 
      _safeGenerateSVGPart(_assetId), 
      '</svg>');
    return string(pack);
  }

  // Returns the number of registered assets
  function getAssetCount() external view returns(uint256) {
    return nextAssetIndex - 1;
  }

  // returns the raw asset data speicified by the assetId (1, ..., count)
  function getRawAsset(uint256 _assetId) external view onlyOwner returns(Asset memory) {
    require(_assetId > 0 && _assetId < nextAssetIndex, "assetId is out of range");
    return assets[_assetId];
  }

  // returns the raw part data specified by the assetId (1, ... count)
  function getRawPart(uint256 _partId) external view onlyOwner returns(Part memory) {
    require(_partId > 0 && _partId < nextPartIndex, "partId is out of range");
    return parts[_partId];
  }
}
