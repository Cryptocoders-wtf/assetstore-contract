// SPDX-License-Identifier: GPL-3.0

/*********************************
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░█████████░░█████████░░░ *
 * ░░░░░░██░░░████░░██░░░████░░░ *
 * ░░██████░░░████████░░░████░░░ *
 * ░░██░░██░░░████░░██░░░████░░░ *
 * ░░██░░██░░░████░░██░░░████░░░ *
 * ░░░░░░█████████░░█████████░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 *********************************/

pragma solidity ^0.8.6;

import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import { ERC721 } from './base/ERC721.sol';
import { ERC721Enumerable } from './base/ERC721Enumerable.sol';
import { Base64 } from 'base64-sol/base64.sol';
import { INounsToken } from './interfaces/INounsToken.sol';
import "@openzeppelin/contracts/utils/Strings.sol";

contract VectorToken is INounsToken, Ownable, ERC721Enumerable {
  using Strings for uint256;
  uint256 private _currentNounId;

  constructor() ERC721('VectorToken', 'VECTORTOKEN') {
  }

  function mint() public override returns (uint256) {
    require(balanceOf(msg.sender) == 0, "You already have one.");
    uint256 tokenId = _currentNounId++;
    _mint(owner(), msg.sender, tokenId);
    emit NounBought(tokenId, msg.sender);
    return tokenId;
  }

  function burn(uint256 nounId) public override onlyOwner {
    require(_exists(nounId), 'URI query for nonexistent token');
    _burn(nounId);
    emit NounBurned(nounId);
  }

  function generateSVG() public pure returns (string memory) {
    return string(_generateSVG());
  }

  function _generateSVG() internal pure returns (bytes memory) {
    return abi.encodePacked(
      '<svg width="1024" height="1024" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg" shape-rendering="crispEdges">\n',
      '<path d="M100,250 Q250,100,300,250" fill="transparent" stroke="#0000ff80" stroke-width="4" />\n',
      '</svg>'      
    );   
  }

  /**
    * @notice A distinct Uniform Resource Identifier (URI) for a given asset.
    * @dev See {IERC721Metadata-tokenURI}.
    */
  function dataURI(uint256 tokenId) public view override returns (string memory) {
    require(_exists(tokenId) || true, 'NounsToken: URI query for nonexistent token');
    string memory nounId = tokenId.toString();
    string memory name = string(abi.encodePacked('VectorToken ', nounId));
    string memory description = string(abi.encodePacked('VectorToken ', nounId, ' is a fun of the Nouns DAO and Nouns Art Festival'));
    string memory image = Base64.encode(_generateSVG());
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

  function tokenURI(uint256 tokenId) public view override returns (string memory) {
    return dataURI(tokenId);
  }
}

