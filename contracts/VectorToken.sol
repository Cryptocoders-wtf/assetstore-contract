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

  function generateSVG(uint256 tokenId) public pure returns (string memory) {
    return string(_generateSVG(tokenId));
  }

  function _generateSVG(uint256 tokenId) internal pure returns (bytes memory) {
    return abi.encodePacked(
      '<svg width="1024" height="1024" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg" shape-rendering="crispEdges">\n',
      '<path d="', _randomPath(tokenId), '" fill="transparent" stroke="#0000ff80" stroke-width="10" />\n',
      '</svg>'      
    );   
  }


  struct Position {
    uint256 x;
    uint256 y;
  }

  function _random(uint256 _seed) internal pure returns (uint256) {
    return uint256(keccak256(abi.encodePacked(_seed)));
  }

  function _randomPath(uint256 tokenId) internal pure returns (bytes memory) {
    uint256 seed = _random(tokenId);
    uint i;
    bytes memory pack;
    for (i = 0 ; i < 32; i++) {
      uint256 x = seed % 1000 + 12;
      seed = _random(seed);
      uint256 y = seed % 1000 + 12;
      seed = _random(seed);
      if (i==0) {
        pack = abi.encodePacked("M", x.toString(), ",", y.toString());
      } else if (i==1) {
        pack = abi.encodePacked(pack, " Q", x.toString(), ",", y.toString());
      } else {
        pack = abi.encodePacked(pack, ",", x.toString(), ",", y.toString());
      }
    }
    return pack;
  }

  /**
    * @notice A distinct Uniform Resource Identifier (URI) for a given asset.
    * @dev See {IERC721Metadata-tokenURI}.
    */
  function dataURI(uint256 tokenId) public view override returns (string memory) {
    require(_exists(tokenId), 'NounsToken: URI query for nonexistent token');
    string memory nounId = tokenId.toString();
    string memory name = string(abi.encodePacked('VectorToken ', nounId));
    string memory description = string(abi.encodePacked('VectorToken ', nounId, ' is a fun of the Nouns DAO and Nouns Art Festival'));
    string memory image = Base64.encode(_generateSVG(tokenId));
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

