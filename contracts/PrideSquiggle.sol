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
import { ERC721Enumerable } from './base/ERC721Enumerable.sol';
import { INounsToken } from './interfaces/INounsToken.sol';
import { ERC721 } from './base/ERC721.sol';
import { IERC721 } from '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import { Base64 } from 'base64-sol/base64.sol';
import { IProxyRegistry } from './external/opensea/IProxyRegistry.sol';
import "@openzeppelin/contracts/utils/Strings.sol";

contract PrideSquiggle is INounsToken, Ownable, ERC721Enumerable {
  using Strings for uint256;

  // The internal noun ID tracker
  uint256 private _currentNounId;

  // developer address.
  address public developer;

  // mint limit
  uint256 public limit;

  // OpenSea's Proxy Registry
  IProxyRegistry public immutable proxyRegistry;

  constructor(
      uint256 _limit,
      address _developer,
      IProxyRegistry _proxyRegistry
    ) ERC721('VectorToken', 'VECTORTOKEN') {
      limit = _limit;
      developer = _developer;
      proxyRegistry = _proxyRegistry;
  }

  /**
    * @notice Override isApprovedForAll to whitelist user's OpenSea proxy accounts to enable gas-less listings.
    */
  function isApprovedForAll(address owner, address operator) public view override(IERC721, ERC721) returns (bool) {
      // Whitelist OpenSea proxy contract for easy trading.
      if (proxyRegistry.proxies(owner) == operator) {
          return true;
      }
      return super.isApprovedForAll(owner, operator);
  }

  /**
    * @notice Anybody can mint, one per wallet.
    */
  function mint() public override returns (uint256) {
    require(balanceOf(msg.sender) == 0, "You already have one.");
    require(_currentNounId < limit, "Sold out.");
    if (_currentNounId % 20 == 2) {
      _mint(owner(), developer, _currentNounId++);
    }
    uint256 tokenId = _currentNounId++;
    _mint(owner(), msg.sender, tokenId);
    emit NounBought(tokenId, msg.sender);
    return tokenId;
  }

  /**
    * @notice Burn a noun.
    */
  function burn(uint256 nounId) public override onlyOwner {
    require(_exists(nounId), 'URI query for nonexistent token');
    _burn(nounId);
    emit NounBurned(nounId);
  }

  /*
    * @notice get next tokenId.
    */
  function getCurrentToken() external view returns (uint256) {                  
      return _currentNounId;
  }

  function generateSVG(uint256 tokenId) public pure returns (string memory) {
    return string(_generateSVG(tokenId));
  }

  function _generateSVG(uint256 tokenId) internal pure returns (bytes memory) {
    bytes memory path = _randomPath(tokenId);
    return abi.encodePacked(
      '<svg width="1024" height="1024" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg" shape-rendering="crispEdges">\n',
      abi.encodePacked('<path d="', path, '" fill="transparent" stroke="#D12229" stroke-width="32" stroke-linecap="round" transform="translate(0,-60)"/>\n'),
      abi.encodePacked('<path d="', path, '" fill="transparent" stroke="#F68A1E" stroke-width="32" stroke-linecap="round" transform="translate(0,-30)" />\n'),
      abi.encodePacked('<path d="', path, '" fill="transparent" stroke="#FDE01A" stroke-width="32" stroke-linecap="round" transform="translate(0,0)" />\n'),
      abi.encodePacked('<path d="', path, '" fill="transparent" stroke="#007940" stroke-width="32" stroke-linecap="round" transform="translate(0,30)" />\n'),
      abi.encodePacked('<path d="', path, '" fill="transparent" stroke="#24408E" stroke-width="32" stroke-linecap="round" transform="translate(0,60)" />\n'),
      abi.encodePacked('<path d="', path, '" fill="transparent" stroke="#732982" stroke-width="32" stroke-linecap="round" transform="translate(0,90)" />\n'),
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
    uint len = 10;
    Position[10] memory pos;
    uint256 last = 100;
    uint256 delta = uint256(1024) * 8 / 10 / (len-1);
    uint256 diff = delta / 3;
    uint256 offset = (1024 - delta * (len-1)) / 2 - diff / 2;
    for (i = 0 ; i < len; i++) {
      uint256 next;
      pos[i].x = offset + i * delta + seed % diff;
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
      pack = abi.encodePacked(pack, (i==1)?" Q":",", pos[i].x.toString(), ",", pos[i].y.toString());
      if (i == len-2) {
        pack = abi.encodePacked(pack, ",", pos[i+1].x.toString(), ",",
                                           pos[i+1].y.toString());
      } else {
        pack = abi.encodePacked(pack, ",", ((pos[i].x + pos[i+1].x)/2).toString(), ",",
                                         ((pos[i].y + pos[i+1].y)/2).toString());
      }
    }
    return pack;
  }

  /**
    * @notice Similar to `tokenURI`, but always serves a base64 encoded data URI
    * with the JSON contents directly inlined.
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

  /**
    * @notice A distinct Uniform Resource Identifier (URI) for a given asset.
    * @dev See {IERC721Metadata-tokenURI}.
    */
  function tokenURI(uint256 tokenId) public view override returns (string memory) {
    return dataURI(tokenId);
  }

  /**
    * @notice Set developer.
    * @dev Only callable by the Owner.
    */
  function setDeveloper(address _developer) external onlyOwner {
      developer = _developer;
  }

  /**
    * @notice Set the limit.
    * @dev Only callable by the Owner.
    */
  function setLimit(uint256 _limit) external onlyOwner {
      limit = _limit;
  }
}

