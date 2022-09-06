// SPDX-License-Identifier: MIT

/*
 * AssetComposer allows developers to create a composition from a collection of
 * assets (in AssetStore) and compositions.
 *
 * Created by Satoshi Nakajima (@snakajima)
 */

pragma solidity ^0.8.6;

import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import { IAssetStore, IAssetStoreEx } from './interfaces/IAssetStore.sol';
import { IAssetProvider, ICategorizedAssetProvider } from './interfaces/IAssetComposer.sol';
import "@openzeppelin/contracts/utils/Strings.sol";
import '@openzeppelin/contracts/interfaces/IERC165.sol';

// IAssetProvider wrapper of AssetStore
contract AssetStoreProvider is ICategorizedAssetProvider, IERC165, Ownable {
  IAssetStoreEx public immutable assetStore;
  string constant providerKey = "asset";

  constructor(IAssetStoreEx _assetStore) {
    assetStore = _assetStore;
  }

  function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
      return
          interfaceId == type(IAssetProvider).interfaceId ||
          interfaceId == type(ICategorizedAssetProvider).interfaceId ||
          interfaceId == type(IERC165).interfaceId;
  }

  function getOwner() external override view returns (address) {
    return owner();
  }

  function getProviderInfo() external view override returns(ProviderInfo memory) {
    return ProviderInfo(providerKey, "Asset Store", this);
  }

  function generateSVGPart(uint256 _assetId) external view override returns(string memory svgPart, string memory tag) {
    IAssetStore.AssetAttributes memory attr = assetStore.getAttributes(_assetId + 1);
    tag = attr.tag;
    svgPart = assetStore.generateSVGPart(_assetId + 1, tag);
  }

  function totalSupply() external view override returns(uint256) {
    return assetStore.getAssetCount();
  }

  function getGroupCount() external view override returns(uint32) {
    return assetStore.getGroupCount();
  }

  function getGroupNameAtIndex(uint32 _groupIndex) external view override returns(string memory) {
    return assetStore.getGroupNameAtIndex(_groupIndex);
  }

  function getCategoryCount(string memory _group) external view override returns(uint32) {
    return assetStore.getCategoryCount(_group);
  }

  function getCategoryNameAtIndex(string memory _group, uint32 _categoryIndex) external view override returns(string memory) {
    return assetStore.getCategoryNameAtIndex(_group, _categoryIndex);
  }

  function getAssetCountInCategory(string memory _group, string memory _category) external view override returns(uint32) {
    return assetStore.getAssetCountInCategory(_group, _category);
  }

  function getAssetIdInCategory(string memory _group, string memory _category, uint32 _assetIndex) external view override returns(uint256) {
    return assetStore.getAssetIdInCategory(_group, _category, _assetIndex) - 1;
  }

  function processPayout(uint256 _assetId, uint256) external override payable {
    IAssetStore.AssetAttributes memory attr = assetStore.getAttributes(_assetId + 1);
    address payable payableTo = payable(attr.soulbound);
    payableTo.transfer(msg.value);
    emit PayedOut(providerKey, _assetId, payableTo, msg.value);
  }
}
