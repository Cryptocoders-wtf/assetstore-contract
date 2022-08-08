// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import { IAssetStore } from './interfaces/IAssetStore.sol';
import "@openzeppelin/contracts/utils/Strings.sol";

contract AssetComposer is Ownable {
  using Strings for uint256;

  mapping(uint256 => uint256[]) private assets;
  IAssetStore public immutable assetStore;

  constructor(
    IAssetStore _assetStore
  ) {
    assetStore = _assetStore;
  }

  function generateSVGPart(uint256 _compositeId) public view returns(string memory, string memory) {
    uint256[] memory assetIds = assets[_compositeId];
    uint256 i;
    bytes memory defs;
    bytes memory uses;
    string memory svgPart;
    string memory tagId;
    for (i=0; i < assetIds.length; i++) {
      uint256 assetId = assetIds[i];
      if (assetId % 2 == 0) {
        (svgPart, tagId) = generateSVGPart(assetId);
      } else {
        assetId /= 2; // odd number indicates assetId * 2 + 1
        IAssetStore.AssetAttributes memory attr = assetStore.getAttributes(assetId);
        tagId = attr.tag;
        svgPart = assetStore.generateSVGPart(assetId, tagId);
      }
      defs = abi.encodePacked(defs, svgPart);
      uses = abi.encodePacked(uses, ' <use href="#', tagId, '" />\n');
    }
    tagId = string(abi.encodePacked('compo', _compositeId.toString()));
    svgPart = string(abi.encodePacked(
      defs,
      '<g id="', tagId, '" >\n',
      uses,
      '</g>'
    ));    
    return (svgPart, tagId);
  }
}
