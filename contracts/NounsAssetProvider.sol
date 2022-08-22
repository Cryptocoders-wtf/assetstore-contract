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
import { IAssetProvider } from './interfaces/IAssetComposer.sol';
import "@openzeppelin/contracts/utils/Strings.sol";
import '@openzeppelin/contracts/interfaces/IERC165.sol';
import { Base64 } from 'base64-sol/base64.sol';
import { INounsDescriptor, INounsSeeder } from './interfaces/INounsDescriptor.sol';

// IAssetProvider wrapper of AssetStore
contract NounsAssetProvider is IAssetProvider, IERC165, Ownable {
  using Strings for uint256;

  INounsDescriptor public immutable descriptor;

  constructor(INounsDescriptor _descriptor) {
    descriptor = _descriptor;
  }

  function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
      return
          interfaceId == type(IAssetProvider).interfaceId ||
          interfaceId == type(IERC165).interfaceId;
  }

  function getOwner() external override view returns (address) {
    return owner();
  }

  function getProviderInfo() external view override returns(ProviderInfo memory) {
    return ProviderInfo("nouns", "Nouns Descriptor", this);
  }

  function generateSVGPart(uint256 _assetId) external view override returns(string memory svgPart, string memory tag) {
    uint256 backgroundCount = descriptor.backgroundCount();
    uint256 bodyCount = descriptor.bodyCount();
    uint256 accessoryCount = descriptor.accessoryCount();
    uint256 headCount = descriptor.headCount();
    uint256 glassesCount = descriptor.glassesCount();

    INounsSeeder.Seed memory seed = INounsSeeder.Seed({
        background: uint48(
            uint48(_assetId) % backgroundCount
        ),
        body: uint48(
            uint48(_assetId >> 48) % bodyCount
        ),
        accessory: uint48(
            uint48(_assetId >> 96) % accessoryCount
        ),
        head: uint48(
            uint48(_assetId >> 144) % headCount
        ),
        glasses: uint48(
            uint48(_assetId >> 192) % glassesCount
        )
    });
    string memory svg = descriptor.generateSVGImage(seed);
    svgPart = string(Base64.decode(svg));
    tag = string(abi.encodePacked("nouns", _assetId.toString()));
  }

  function totalSupply() external pure override returns(uint256) {
    return 0; // indicating "dynamically (but deterministically) generated from the given assetId)
  }
}
