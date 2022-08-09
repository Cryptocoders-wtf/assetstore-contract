// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

// IAssetStore is the inteface for consumers of the AsseCompoer.
interface IAssetComposer {
  struct AssetLayer {
    uint256 assetId; // either compositeId or assetId
    bool isComposition;   
    string fill; // optional fill color
    string transform; // optinal transform
  }

  event CompositionRegistered(address from, uint256 compositionId);

  function register(AssetLayer[] memory _infos) external returns(uint256);
  function getCompositionCount() external view returns(uint256);
  function generateSVGPart(uint256 _compositionId) external view returns(string memory, string memory);
}