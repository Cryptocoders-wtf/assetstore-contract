// SPDX-License-Identifier: MIT

/*
 * NounsAssetProvider is a wrapper around NounsDescriptor so that it offers
 * various characters as assets to compose (not individual parts).
 *
 * Created by Satoshi Nakajima (@snakajima)
 */

pragma solidity ^0.8.6;

import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import { IAssetStore, IAssetStoreEx } from './interfaces/IAssetStore.sol';
import { IAssetProvider } from './interfaces/IAssetProvider.sol';
import { ISVGHelper } from './interfaces/ISVGHelper.sol';
import { SplatterProvider } from './SplatterProvider.sol';
import './libs/Trigonometry.sol';
import './libs/Randomizer.sol';
import './libs/SVGHelper.sol';
import "@openzeppelin/contracts/utils/Strings.sol";
import '@openzeppelin/contracts/interfaces/IERC165.sol';
import "hardhat/console.sol";

contract SplatterArtProvider is IAssetProvider, IERC165, Ownable {
  using Strings for uint32;
  using Strings for uint256;
  using Randomizer for Randomizer.Seed;
  using Trigonometry for uint;

  string constant providerKey = "spltart";
  SplatterProvider public splatter;

  constructor(SplatterProvider _splatter) {
    splatter = _splatter;
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
    return ProviderInfo(providerKey, "Splatter Art", this);
  }

  function totalSupply() external pure override returns(uint256) {
    return 10; 
  }

  function processPayout(uint256 _assetId) external override payable {
    splatter.processPayout(_assetId);
  }

  function generateSVGPart(uint256 _assetId) external view override returns(string memory svgPart, string memory tag) {
    Randomizer.Seed memory seed = Randomizer.Seed(_assetId/4, 0);
    uint count = 30;
    uint length = 40;
    uint dot = 100;
    (seed, count) = seed.randomize(count, 50); // +/- 50%
    (seed, length) = seed.randomize(length, 50); // +/- 50%
    (seed, dot) = seed.randomize(dot, 50);
    count = count / 3 * 3; // always multiple of 3

    bytes memory path;
    (,path) = splatter.generatePath(seed, count, length, dot);

    tag = string(abi.encodePacked(providerKey, _assetId.toString()));
    svgPart = string(abi.encodePacked(
      '<g id="', tag, '">\n'
      '<path d="', path, '" fill="green" />\n'
      '</g>\n'
    ));
  }
}