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

  /**
    * @notice A distinct Uniform Resource Identifier (URI) for a given asset.
    * @dev See {IERC721Metadata-tokenURI}.
    */
  function dataURI(uint256 tokenId) public view override returns (string memory) {
    require(_exists(tokenId), 'NounsToken: URI query for nonexistent token');
    string memory nounId = tokenId.toString();
    string memory name = string(abi.encodePacked('VectorToken ', nounId));
    string memory description = string(abi.encodePacked('VectorToken ', nounId, ' is a fun of the Nouns DAO and Nouns Art Festival'));
    string memory image = Base64.encode('<svg width="320" height="320" viewBox="0 0 320 320" xmlns="http://www.w3.org/2000/svg" shape-rendering="crispEdges"><rect width="100%" height="100%" fill="#d5d7e1" /><rect width="140" height="10" x="90" y="210" fill="#80a72d" /><rect width="140" height="10" x="90" y="220" fill="#80a72d" /><rect width="140" height="10" x="90" y="230" fill="#80a72d" /><rect width="140" height="10" x="90" y="240" fill="#80a72d" /><rect width="20" height="10" x="90" y="250" fill="#80a72d" /><rect width="110" height="10" x="120" y="250" fill="#80a72d" /><rect width="20" height="10" x="90" y="260" fill="#80a72d" /><rect width="110" height="10" x="120" y="260" fill="#80a72d" /><rect width="20" height="10" x="90" y="270" fill="#80a72d" /><rect width="110" height="10" x="120" y="270" fill="#80a72d" /><rect width="20" height="10" x="90" y="280" fill="#80a72d" /><rect width="110" height="10" x="120" y="280" fill="#80a72d" /><rect width="20" height="10" x="90" y="290" fill="#80a72d" /><rect width="110" height="10" x="120" y="290" fill="#80a72d" /><rect width="20" height="10" x="90" y="300" fill="#80a72d" /><rect width="110" height="10" x="120" y="300" fill="#80a72d" /><rect width="20" height="10" x="90" y="310" fill="#80a72d" /><rect width="110" height="10" x="120" y="310" fill="#80a72d" /><rect width="10" height="10" x="140" y="240" fill="#70e890" /><rect width="10" height="10" x="170" y="240" fill="#70e890" /><rect width="20" height="10" x="150" y="250" fill="#70e890" /><rect width="20" height="10" x="150" y="260" fill="#70e890" /><rect width="10" height="10" x="140" y="270" fill="#70e890" /><rect width="10" height="10" x="170" y="270" fill="#70e890" /><rect width="40" height="10" x="150" y="20" fill="#eff2fa" /><rect width="60" height="10" x="150" y="30" fill="#eff2fa" /><rect width="30" height="10" x="140" y="40" fill="#eff2fa" /><rect width="10" height="10" x="170" y="40" fill="#26b1f3" /><rect width="10" height="10" x="180" y="40" fill="#eff2fa" /><rect width="10" height="10" x="190" y="40" fill="#26b1f3" /><rect width="10" height="10" x="200" y="40" fill="#eff2fa" /><rect width="20" height="10" x="140" y="50" fill="#eff2fa" /><rect width="10" height="10" x="160" y="50" fill="#26b1f3" /><rect width="10" height="10" x="170" y="50" fill="#1929f4" /><rect width="10" height="10" x="180" y="50" fill="#26b1f3" /><rect width="10" height="10" x="190" y="50" fill="#1929f4" /><rect width="10" height="10" x="200" y="50" fill="#eff2fa" /><rect width="20" height="10" x="140" y="60" fill="#eff2fa" /><rect width="20" height="10" x="160" y="60" fill="#257ced" /><rect width="10" height="10" x="180" y="60" fill="#26b1f3" /><rect width="10" height="10" x="190" y="60" fill="#257ced" /><rect width="10" height="10" x="200" y="60" fill="#eff2fa" /><rect width="50" height="10" x="110" y="70" fill="#eff2fa" /><rect width="10" height="10" x="160" y="70" fill="#257ced" /><rect width="10" height="10" x="170" y="70" fill="#26b1f3" /><rect width="10" height="10" x="180" y="70" fill="#1929f4" /><rect width="10" height="10" x="190" y="70" fill="#26b1f3" /><rect width="10" height="10" x="200" y="70" fill="#eff2fa" /><rect width="110" height="10" x="100" y="80" fill="#eff2fa" /><rect width="110" height="10" x="90" y="90" fill="#eff2fa" /><rect width="130" height="10" x="80" y="100" fill="#eff2fa" /><rect width="140" height="10" x="70" y="110" fill="#eff2fa" /><rect width="10" height="10" x="210" y="110" fill="#a3baed" /><rect width="40" height="10" x="60" y="120" fill="#eff2fa" /><rect width="100" height="10" x="110" y="120" fill="#eff2fa" /><rect width="30" height="10" x="210" y="120" fill="#a3baed" /><rect width="40" height="10" x="50" y="130" fill="#eff2fa" /><rect width="100" height="10" x="110" y="130" fill="#eff2fa" /><rect width="50" height="10" x="210" y="130" fill="#a3baed" /><rect width="40" height="10" x="40" y="140" fill="#eff2fa" /><rect width="110" height="10" x="100" y="140" fill="#eff2fa" /><rect width="70" height="10" x="210" y="140" fill="#a3baed" /><rect width="40" height="10" x="20" y="150" fill="#eff2fa" /><rect width="120" height="10" x="90" y="150" fill="#eff2fa" /><rect width="50" height="10" x="240" y="150" fill="#a3baed" /><rect width="30" height="10" x="20" y="160" fill="#eff2fa" /><rect width="120" height="10" x="90" y="160" fill="#eff2fa" /><rect width="10" height="10" x="250" y="160" fill="#a3baed" /><rect width="10" height="10" x="270" y="160" fill="#a3baed" /><rect width="110" height="10" x="90" y="170" fill="#eff2fa" /><rect width="80" height="10" x="90" y="180" fill="#eff2fa" /><rect width="20" height="10" x="170" y="180" fill="#5fd4fb" /><rect width="20" height="10" x="190" y="180" fill="#eff2fa" /><rect width="20" height="10" x="100" y="190" fill="#a3baed" /><rect width="100" height="10" x="120" y="190" fill="#eff2fa" /><rect width="60" height="10" x="90" y="200" fill="#a3baed" /><rect width="80" height="10" x="150" y="200" fill="#eff2fa" /><rect width="60" height="10" x="100" y="110" fill="#8dd122" /><rect width="60" height="10" x="170" y="110" fill="#8dd122" /><rect width="10" height="10" x="100" y="120" fill="#8dd122" /><rect width="20" height="10" x="110" y="120" fill="#ffffff" /><rect width="20" height="10" x="130" y="120" fill="#000000" /><rect width="10" height="10" x="150" y="120" fill="#8dd122" /><rect width="10" height="10" x="170" y="120" fill="#8dd122" /><rect width="20" height="10" x="180" y="120" fill="#ffffff" /><rect width="20" height="10" x="200" y="120" fill="#000000" /><rect width="10" height="10" x="220" y="120" fill="#8dd122" /><rect width="40" height="10" x="70" y="130" fill="#8dd122" /><rect width="20" height="10" x="110" y="130" fill="#ffffff" /><rect width="20" height="10" x="130" y="130" fill="#000000" /><rect width="30" height="10" x="150" y="130" fill="#8dd122" /><rect width="20" height="10" x="180" y="130" fill="#ffffff" /><rect width="20" height="10" x="200" y="130" fill="#000000" /><rect width="10" height="10" x="220" y="130" fill="#8dd122" /><rect width="10" height="10" x="70" y="140" fill="#8dd122" /><rect width="10" height="10" x="100" y="140" fill="#8dd122" /><rect width="20" height="10" x="110" y="140" fill="#ffffff" /><rect width="20" height="10" x="130" y="140" fill="#000000" /><rect width="10" height="10" x="150" y="140" fill="#8dd122" /><rect width="10" height="10" x="170" y="140" fill="#8dd122" /><rect width="20" height="10" x="180" y="140" fill="#ffffff" /><rect width="20" height="10" x="200" y="140" fill="#000000" /><rect width="10" height="10" x="220" y="140" fill="#8dd122" /><rect width="10" height="10" x="70" y="150" fill="#8dd122" /><rect width="10" height="10" x="100" y="150" fill="#8dd122" /><rect width="20" height="10" x="110" y="150" fill="#ffffff" /><rect width="20" height="10" x="130" y="150" fill="#000000" /><rect width="10" height="10" x="150" y="150" fill="#8dd122" /><rect width="10" height="10" x="170" y="150" fill="#8dd122" /><rect width="20" height="10" x="180" y="150" fill="#ffffff" /><rect width="20" height="10" x="200" y="150" fill="#000000" /><rect width="10" height="10" x="220" y="150" fill="#8dd122" /><rect width="60" height="10" x="100" y="160" fill="#8dd122" /><rect width="60" height="10" x="170" y="160" fill="#8dd122" /></svg>');
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

