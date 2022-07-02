// SPDX-License-Identifier: MIT

/*
 * On-chain asset store, which allows multiple smart contracts to shara vector assets.
 *
 * All assets registered to this store will be treated as cc0 (public domain), 
 * CC-BY-SA(Attribution-ShareAlike) 2.0, Apache 2.0, MIT, or something similar 
 * (should be specified in the "group"). If the attribution is required, 
 * the creater's name should be either in the "group", "category" or "name".
 *
 * All registered assets will be available to other smart contracts for free, including
 * commecial services. Therefore, it is not allowed to register assets that require
 * any form of commercial licenses. 
 *
 * Once an asset is registed with group/category/name, it is NOT possible to update,
 * which guaranttees the availability in future.
 *
 * Please respect those people who paid gas fees to register those assets. 
 * Their wallet addresses are permanently stored as the "souldbound" attribute
 * of each asset (which is accessible via getAttributes). Using those addressed 
 * for air-drops and whitelisting is one way to appreciate their efforts. 
 * 
 * Created by Satoshi Nakajima (@snakajima)
 */

pragma solidity ^0.8.6;

import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import { IAssetStoreRegistry, IAssetStore } from './interfaces/IAssetStore.sol';
import { IStringValidator } from './interfaces/IStringValidator.sol';
import "@openzeppelin/contracts/utils/Strings.sol";
import './libs/StringValidator.sol';
import './libs/StringSet.sol';
import './libs/SVGPathDecoder.sol';

// import "hardhat/console.sol";

/*
 * Abstract contract that implements the categolized asset storage system. 
 */
abstract contract AssetStoreCore is Ownable, IAssetStoreRegistry {
  using StringSet for StringSet.Set;
  using Strings for uint16;
  using Strings for uint256;
  struct Asset {
    uint32 groupId;    // index to groups + 1
    uint32 categoryId; // index to categories + 1
    string name;
    string minter;
    address soulbound;
    uint256[] partsIds;
  }

  // Upgradable string validator
  IStringValidator validator;

  // Upgradable path decoder
  IPathDecoder decoder;

  // asset & part database
  mapping(uint256 => Asset) private assets;
  uint256 private nextAssetIndex = 1; // 0 indicates an error
  mapping(uint256 => Part) private parts;
  uint256 private nextPartIndex = 1; // 0 indicates an error

  // Groups and categories(for browsing)
  StringSet.Set internal groupSet;
  mapping(uint32 => StringSet.Set) internal categorySets;
  
  // Grouped and categorized assetIds (for browsing)
  struct AssetCatalog {
    mapping(uint32 => uint256) assetIds; 
    uint32 nextAssetIndex;
    mapping(string => uint256) assetNameToId;
  }
  mapping(string => mapping(string => AssetCatalog)) internal assetCatalogs;

  constructor() {
    validator = new StringValidator(); // default validator
    decoder = new SVGPathDecoder(); // default decoder
  }

  /*
   * Returns the groupId of the specified group, creating a new Id if necessary.
   * @notice gruopId == groupIndex + 1
   */
  function _getGroupId(string memory group) private returns(uint32) {
    (uint32 id, bool created) = groupSet.getOrCreateId(group, validator);
    if (created) {
      emit GroupAdded(group); 
    }
    return id;
  }

  /*
   * Returns the categoryId of the specified category in a group, creating a new Id if necessary.
   * The categoryId is unique only within that group. 
   * @notice categoryId == categoryIndex + 1
   */
  function _getCategoryId(string memory group, uint32 groupId, string memory category) private returns(uint32) {
    StringSet.Set storage categorySet =  categorySets[groupId];
    (uint32 id, bool created) = categorySet.getOrCreateId(category, validator);
    if (created) {
      emit CategoryAdded(group, category);
    }
    return id;
  }

  /*
   * Register a Part and returns its id, which is its index in parts[].
   */
  function _registerPart(Part memory _part) private returns(uint256) {
    parts[nextPartIndex++] = _part;
    return nextPartIndex-1;    
  }

  /*
   * We need to validate any strings embedded in SVG to prevent malicious injections. 
   * @notice: group and catalog are validated in Stringset.getId(). 
   *  The body is a binary format, which will be validated when we decode.
   */
  modifier validateAsset(AssetInfo memory _assetInfo) {
    uint size = _assetInfo.parts.length;
    uint i;
    for (i=0; i < size; i++) {
      Part memory part = _assetInfo.parts[i];
      require(validator.validate(bytes(part.color)), "Invalid AssetData Color");
    }
    require(validator.validate(bytes(_assetInfo.name)), "Invalid AssetData Name");
    _;
  }

  /*
   * Register an Asset and returns its id, which is its index in assets[].
   */
  function _registerAsset(AssetInfo memory _assetInfo) internal validateAsset(_assetInfo) returns(uint256) {
    require(assetCatalogs[_assetInfo.group][_assetInfo.category].assetNameToId[_assetInfo.name] == 0, "Asset already exists with the same group, category and name");
    uint size = _assetInfo.parts.length;
    uint256[] memory partsIds = new uint256[](size);
    uint i;
    for (i=0; i<size; i++) {
      partsIds[i] = _registerPart(_assetInfo.parts[i]);
    }
    uint256 assetId = nextAssetIndex++;
    Asset memory asset;
    asset.name = _assetInfo.name;
    asset.soulbound = _assetInfo.soulbound;
    asset.minter = _assetInfo.minter; // @notice: no validation
    asset.groupId = _getGroupId(_assetInfo.group);
    asset.categoryId = _getCategoryId(_assetInfo.group, asset.groupId, _assetInfo.category);
    asset.partsIds = partsIds;

    assets[assetId] = asset;
    assetCatalogs[_assetInfo.group][_assetInfo.category].assetIds[assetCatalogs[_assetInfo.group][_assetInfo.category].nextAssetIndex++] = assetId;
    assetCatalogs[_assetInfo.group][_assetInfo.category].assetNameToId[_assetInfo.name] = assetId;

    emit AssetRegistered(msg.sender, assetId);
    return assetId;
  }

  // Returns the number of registered assets
  function getAssetCount() external view onlyOwner returns(uint256) {
    return nextAssetIndex - 1;
  }

  modifier assetExists(uint256 _assetId) {
    require(_assetId > 0 && _assetId < nextAssetIndex, "AssetStore: assetId is out of range"); 
    _;
  }

  modifier partExists(uint256 _partId) {
    require(_partId > 0 && _partId < nextPartIndex, "partId is out of range");
    _;
  }

  // This allows us to keep the assets private. 
  function _getAsset(uint256 _assetId) internal view assetExists(_assetId) returns(Asset memory) {
    return assets[_assetId];
  }

  // This allows us to keep the parts private. 
  function _getPart(uint256 _partId) internal view partExists(_partId) returns(Part memory) {
    return parts[_partId];
  }
}

/*
 * Abstract contract that implements various adminstrative functions, such as
 * managing the whitelist, disable/enable assets and accessing the raw data.
 */
abstract contract AssetStoreAdmin is AssetStoreCore {
  constructor() {
    whitelist[msg.sender] = true;
  }

  /*
   * Whitelist manages the list of contracts which can register assets
   * In future, we disable the whitelist allowing anybody to register assets.
   */
  mapping(address => bool) whitelist;
  bool disableWhitelist = false;

  /*
   * It allows us to disable indivial assets, just in case. 
   */
  mapping(uint256 => bool) disabled;

  function setWhitelistStatus(address _address, bool _status) external onlyOwner {
    whitelist[_address] = _status;
  }

  function setDisabled(uint256 _assetId, bool _status) external assetExists(_assetId) onlyOwner {
    disabled[_assetId] = _status;
  }

  function setDisableWhitelist(bool _disable) external onlyOwner {
    disableWhitelist = _disable;
  } 

  function setValidator(IStringValidator _validator) external onlyOwner {
    validator = _validator;
  }

  function setPathDecoder(IPathDecoder _decoder) external onlyOwner {
    decoder = _decoder;
  }

  // returns the raw asset data speicified by the assetId (1, ..., count)
  function getRawAsset(uint256 _assetId) external view onlyOwner returns(Asset memory) {
    return _getAsset(_assetId);
  }

  // returns the raw part data specified by the assetId (1, ... count)
  function getRawPart(uint256 _partId) external view onlyOwner returns(Part memory) {
    return _getPart(_partId);
  }
}

/*
 * Concreate contract that implements IAssetStoreRegistory
 * Even though this is a concreate contract, we will never deploy this contract directly. 
 */
contract AppStoreRegistory is AssetStoreAdmin {
  modifier onlyWhitelist {
    require(disableWhitelist || whitelist[msg.sender], "AssetStore: The sender must be in the white list.");
    _;
  }
   
  function registerAsset(AssetInfo memory _assetInfo) external override onlyWhitelist returns(uint256) {
    return _registerAsset(_assetInfo);
  }

  function registerAssets(AssetInfo[] memory _assetInfos) external override onlyWhitelist {
    uint i;
    for (i=0; i<_assetInfos.length; i++) {
      _registerAsset(_assetInfos[i]);
    }
  }
}

/*
 * Concreate contract that implements both IAssetStore and IAssetStoreRegistory
 * This is the contract we deploy to the blockchain.
 */
contract AssetStore is AppStoreRegistory, IAssetStore {
  using Strings for uint16;
  using Strings for uint256;
  using StringSet for StringSet.Set;

  modifier enabled(uint256 _assetId) {
    require(disabled[_assetId] != true, "AssetStore: this asset is diabled");
    _;    
  }

  // Returns the number of registered groups.
  function getGroupCount() external view override returns(uint32) {
    return groupSet.getCount();
  }

  // Returns the name of a group specified with groupIndex (groupId - 1). 
  function getGroupNameAtIndex(uint32 _groupIndex) external view override returns(string memory) {
    return groupSet.nameAtIndex(_groupIndex);
  }

  // Returns the number of categories in the specified group.
  function getCategoryCount(string memory _group) external view override returns(uint32) {
    return categorySets[groupSet.getId(_group)].getCount();
  }

  // Returns the name of category specified with group/categoryIndex pair.
  function getCategoryNameAtIndex(string memory _group, uint32 _categoryIndex) external view override returns(string memory) {
    return categorySets[groupSet.getId(_group)].nameAtIndex(_categoryIndex);
  }

  // Returns the number of asset in the specified group/category. 
  function getAssetCountInCategory(string memory _group, string memory _category) external view override returns(uint32) {
    return assetCatalogs[_group][_category].nextAssetIndex;
  }

  // Returns the assetId of the specified group/category/assetIndex. 
  function getAssetIdInCategory(string memory _group, string memory _category, uint32 _assetIndex) external view override returns(uint256) {
    require(_assetIndex < assetCatalogs[_group][_category].nextAssetIndex, "The assetIndex is out of range");
    return assetCatalogs[_group][_category].assetIds[_assetIndex];
  }

  // Returns the assetId of the specified group/category/name. 
  function getAssetIdWithName(string memory _group, string memory _category, string memory _name) external override view returns(uint256) {
    return assetCatalogs[_group][_category].assetNameToId[_name];
  }

  function _getDescription(Asset memory asset) internal view returns(bytes memory) {
    string memory group = groupSet.nameAtIndex(asset.groupId - 1);
    return abi.encodePacked(group, '/', categorySets[asset.groupId].nameAtIndex(asset.categoryId - 1), '/', asset.name);
  }

  /*
   * Generate an id for SVG based on the assetId.
   */
  function _tagForAsset(uint256 _assetId) internal pure returns(string memory) {
    return string(abi.encodePacked('asset', _assetId.toString()));
  }

  function _safeGenerateSVGPart(uint256 _assetId) internal view returns(bytes memory) {
    Asset memory asset = _getAsset(_assetId);
    uint256[] memory indeces = asset.partsIds;
    bytes memory pack = abi.encodePacked(' <g id="', _tagForAsset(_assetId), '" desc="', _getDescription(asset), '">\n');
    uint i;
    for (i=0; i<indeces.length; i++) {
      Part memory part = _getPart(indeces[i]);
      bytes memory color;
      if (bytes(part.color).length > 0) {
        color = abi.encodePacked(' fill="', part.color ,'"');
      }
      pack = abi.encodePacked(pack, '  <path d="', decoder.decodePath(part.body), '"', color,' />\n');
    }
    pack = abi.encodePacked(pack, ' </g>\n');
    return pack;
  }

  // returns a SVG part with the specified asset
  function generateSVGPart(uint256 _assetId) external override view enabled(_assetId) returns(string memory) {
    return string(_safeGenerateSVGPart(_assetId));
  }

  // returns a full SVG with the specified asset
  function generateSVG(uint256 _assetId) external override view enabled(_assetId) returns(string memory) {
    bytes memory pack = abi.encodePacked(
      '<svg viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">\n', 
      _safeGenerateSVGPart(_assetId), 
      '</svg>');
    return string(pack);
  }

  // returns the attributes of the specified asset
  function getAttributes(uint256 _assetId) external view override returns(AssetAttributes memory) {
    Asset memory asset = _getAsset(_assetId);
    AssetAttributes memory attr;
    attr.name = asset.name;
    attr.tag = _tagForAsset(_assetId);
    attr.soulbound = asset.soulbound;
    attr.minter = asset.minter;
    attr.group = groupSet.nameAtIndex(asset.groupId - 1);
    attr.category = categorySets[asset.groupId].nameAtIndex(asset.categoryId - 1);
    attr.width = 1024;
    attr.height = 1024;
    return attr;
  }
}
