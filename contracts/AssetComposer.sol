// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import { IAssetStore } from './interfaces/IAssetStore.sol';
import { IStringValidator } from './interfaces/IStringValidator.sol';
import "@openzeppelin/contracts/utils/Strings.sol";

contract AssetComposer is Ownable {
  using Strings for uint256;

  IAssetStore public immutable assetStore;
  uint256 public nextId;

  mapping(uint256 => uint256[]) private assets; // compositeId => [assetIds]
  mapping(uint256 => mapping(uint256 => bytes)) private transforms;
  mapping(uint256 => mapping(uint256 => bytes)) private fills;

  constructor(
    IAssetStore _assetStore
  ) {
    assetStore = _assetStore;
  }

  struct AssetInfo {
    uint256 assetId; // either compositeId or assetId
    bool isComposition;   
    string fill; // optional fill color
    string transform; // optinal transform
  }

  function register(AssetInfo[] memory _infos) external returns(uint256) {
    IStringValidator validator = assetStore.getStringValidator();
    uint256 compositionId = nextId++;
    //uint256 assetCount = assetStore.getAssetCount();
    uint256 i;
    uint256[] storage assetIds = assets[compositionId];
    for (i=0; i<_infos.length; i++) {
      AssetInfo memory info = _infos[i];
      uint256 assetId = info.assetId;
      if (info.isComposition) {
        require(assetId < nextId, "register: Invalid compositionId");
        assetId *= 2; // @notice
      } else {
        //require(assetId < assetCount, "register: Invalid assetId");
        assetId = assetId * 2 + 1; // @notice
      }
      assetIds.push(assetId);
      bytes memory transform = bytes(info.transform);
      if (transform.length > 0) {
        require(validator.validate(transform), "register: Invalid transform");
        transforms[compositionId][assetId] = transform;
      }
      bytes memory fill = bytes(info.fill);
      if (fill.length > 0) {
        require(validator.validate(fill), "register: Invalid fill");
        fills[compositionId][assetId] = fill;
      }
    }
    return compositionId;
  }

  function generateSVGPart(uint256 _compositionId) public view returns(string memory, string memory) {
    uint256[] memory assetIds = assets[_compositionId];
    uint256 i;
    bytes memory defs;
    bytes memory uses;
    string memory svgPart;
    string memory tagId;
    for (i=0; i < assetIds.length; i++) {
      uint256 assetId = assetIds[i];
      if (assetId % 2 == 0) {
        (svgPart, tagId) = generateSVGPart(assetId/2);
      } else {
        IAssetStore.AssetAttributes memory attr = assetStore.getAttributes(assetId/2);
        tagId = attr.tag;
        svgPart = assetStore.generateSVGPart(assetId/2, tagId);
      }
      defs = abi.encodePacked(defs, svgPart);
      uses = abi.encodePacked(uses, ' <use href="#', tagId, '"');
      bytes memory transform = transforms[_compositionId][assetId];
      if (transform.length > 0) {
        uses = abi.encodePacked(uses, ' transform="', transform, '"');
      }
      bytes memory fill = fills[_compositionId][assetId];
      if (fill.length > 0) {
        uses = abi.encodePacked(uses, ' fill="', fill, '"');
      }
      uses = abi.encodePacked(uses, ' />\n');
    }
    tagId = string(abi.encodePacked('comp', _compositionId.toString()));
    svgPart = string(abi.encodePacked(
      defs,
      '<g id="', tagId, '" >\n',
      uses,
      '</g>'
    ));    
    return (svgPart, tagId);
  }
}
