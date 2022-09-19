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
  uint constant stylesPerSeed = 2;
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
    return 30; 
  }

  function processPayout(uint256 _assetId) external override payable {
    splatter.processPayout(_assetId);
  }

  function getColorScheme(Randomizer.Seed memory _seed) internal pure returns(Randomizer.Seed memory, string[] memory) {
    Randomizer.Seed memory seed = _seed;

    string[5] memory source;
    uint i;
    (seed, i) = seed.random(3);
    if (i == 0) {
      source =["E9B4DB", "6160B0", "EB77A6", "3E3486", "E23D80"]; // love
    } else if (i == 1) {
      source =["FFDE91", "FF9D75", "DE6868", "494580", "BDA8FF"]; // bright
    } else {
      source =["5A261B", "C81125", "F15B4A", "FFAB63", "FADB6A"]; // fall
    }
    string[] memory scheme = new string[](5);
    uint offset;
    (seed, offset) = seed.random(scheme.length);
    for (i = 0; i < 5 ; i++) {
      scheme[i] = source[(i + offset) % 5];
    }
    return (seed, scheme);
  }

  function generateSVGPart(uint256 _assetId) external view override returns(string memory svgPart, string memory tag) {
    Randomizer.Seed memory seed = Randomizer.Seed(_assetId/stylesPerSeed, 0);
    uint count = 30;
    uint length = 40;
    uint dot = 100;
    (seed, count) = seed.randomize(count, 50); // +/- 50%
    (seed, length) = seed.randomize(length, 50); // +/- 50%
    (seed, dot) = seed.randomize(dot, 50);
    count = count / 3 * 3; // always multiple of 3

    bytes memory path;
    tag = string(abi.encodePacked(providerKey, _assetId.toString()));
    uint256 style = _assetId % stylesPerSeed;
    bytes memory body;
    string[] memory scheme;
    (seed, scheme) = getColorScheme(seed);

    if (style == 0) {
    (seed, path) = splatter.generatePath(seed, count, length, dot);
      body = abi.encodePacked('<path d="', path, '" fill="#', scheme[0], '" />\n');
    } else if (style == 1) {
      uint colorLength = scheme.length;
      for (uint i = 0; i < colorLength; i++) {
        uint256 angle = 0x4000 * i / colorLength;
        (seed, path) = splatter.generatePath(seed, count, length, dot);
        body = abi.encodePacked(body, '<path d="', path, '" fill="#', scheme[i], '" transform="translate(',
          uint256(212 + 212 * angle.cos() / 0x7fff).toString(), ',',
          uint256(212 + 212 * angle.sin() / 0x7fff).toString(),
          ') scale(0.586, 0.586)" />\n');
      }
    }

    svgPart = string(abi.encodePacked(
      '<g id="', tag, '">\n',
      body,
      '</g>\n'
    ));
  }
}