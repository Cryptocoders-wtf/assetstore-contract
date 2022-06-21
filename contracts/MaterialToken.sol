// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.6;

import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import { Base64 } from 'base64-sol/base64.sol';
import "@openzeppelin/contracts/utils/Strings.sol";

contract MaterialToken is Ownable, ERC721Enumerable {
  using Strings for uint256;

  // description
  string public description = "Celebrating Pride Month 2022";

  // The internal token ID tracker
  uint256 private _currentTokenId;

  constructor() ERC721("Material Icons", "MATERIAL") {
  }

  function mint() external onlyOwner returns(uint256) {
    uint256 tokenId = _currentTokenId++;
    _mint(owner(), tokenId);
    return tokenId;    
  }

  /**
    * @notice A distinct Uniform Resource Identifier (URI) for a given asset.
    * @dev See {IERC721Metadata-tokenURI}.
    */
  function tokenURI(uint256 tokenId) public view override returns (string memory) {
    require(_exists(tokenId), 'MaterialToken: URI query for nonexistent token');
    string memory stringId = tokenId.toString();
    string memory name = string(abi.encodePacked('Pride Squiggle #', stringId));
    string memory image = Base64.encode("abc");
    return string(
      abi.encodePacked(
        'data:application/json;base64,',
        Base64.encode(
          bytes(
            abi.encodePacked('{"name":"', name, '", "description":"', description, '", "image": "', 'data:image/svg+xml;base64,', image, '"}')
          )
        )
      )
    );
  }  
}