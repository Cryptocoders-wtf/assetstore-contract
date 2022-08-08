// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

// IAssetStore is the inteface for consumers of the AsseCompoer.
interface IAssetComposer {
  struct AssetInfo {
    uint256 assetId; // either compositeId or assetId
    bool isComposition;   
    string fill; // optional fill color
    string transform; // optinal transform
  }

  function register(AssetInfo[] memory _infos) external returns(uint256);
  function generateSVGPart(uint256 _compositionId) external view returns(string memory, string memory);
}