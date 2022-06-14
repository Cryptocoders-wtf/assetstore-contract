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
    bytes memory path = _randomPath(tokenId);
    return abi.encodePacked(
      '<svg width="1024" height="1024" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg" shape-rendering="crispEdges">\n',
      abi.encodePacked('<path d="', path, '" fill="transparent" stroke="#D12229" stroke-width="32" stroke-linecap="round" />\n'),
      abi.encodePacked('<path d="', path, '" fill="transparent" stroke="#F68A1E" stroke-width="32" stroke-linecap="round" transform="translate(0,20)" />\n'),
      abi.encodePacked('<path d="', path, '" fill="transparent" stroke="#FDE01A" stroke-width="32" stroke-linecap="round" transform="translate(0,40)" />\n'),
      abi.encodePacked('<path d="', path, '" fill="transparent" stroke="#007940" stroke-width="32" stroke-linecap="round" transform="translate(0,60)" />\n'),
      abi.encodePacked('<path d="', path, '" fill="transparent" stroke="#24408E" stroke-width="32" stroke-linecap="round" transform="translate(0,80)" />\n'),
      abi.encodePacked('<path d="', path, '" fill="transparent" stroke="#732982" stroke-width="32" stroke-linecap="round" transform="translate(0,100)" />\n'),
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
    uint len = 9;
    Position[9] memory pos;
    uint256 last = 100;
    for (i = 0 ; i < len; i++) {
      uint256 next;
      pos[i].x = (1024 - 100 * 8) + i * 100;
      seed = _random(seed);
      if (last < 512) {
        next = last + seed % ((1024 - last) * 8 / 10);
      } else {
        next = last - seed % (last * 8 / 10);
      }
      pos[i].y = next;
      last = next;
      seed = _random(seed);
    }
    bytes memory pack;
    pack = abi.encodePacked("M", ((pos[0].x + pos[1].x)/2).toString(), ",",
                                 ((pos[0].y + pos[1].y)/2).toString());
    for (i = 1 ; i < len-1; i++) {
      uint j = i % len;
      pack = abi.encodePacked(pack, (i==1)?" Q":",", pos[j].x.toString(), ",", pos[j].y.toString());
      pack = abi.encodePacked(pack, ",", ((pos[j].x + pos[(j+1)%len].x)/2).toString(), ",",
                                         ((pos[j].y + pos[(j+1)%len].y)/2).toString());
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

