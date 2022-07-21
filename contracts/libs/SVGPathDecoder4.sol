// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/utils/Strings.sol";
import "../interfaces/IPathDecoder.sol";

pragma solidity ^0.8.6;

contract SVGPathDecoder4 is IPathDecoder {
  using Strings for uint16;

  function merge(bytes[] memory _array) internal pure returns(bytes[] memory) {
    uint256 length = _array.length / 2;
    bool isOdd = (_array.length % 2 == 1);
    bytes[] memory ret;
    if (isOdd) {
      ret = new bytes[](length + 1);
    } else {
      ret = new bytes[](length);
    }
    uint256 i;
    for (i=0; i<length; i++) {
      ret[i] = abi.encodePacked(_array[i*2], _array[i]);
    }
    if (isOdd) {
      ret[length] = _array[length*2];
    }
    return ret;
  }
  /**
  * Decode the compressed binary deta and reconstruct SVG path. 
  * The binaryformat is 12-bit middle endian, where the low 4-bit of the middle byte is
  * the high 4-bit of the even item ("ijkl"), and the high 4-bit of the middle byte is the high
  * 4-bit of the odd item ("IJKL"). 
  *   abcdefgh ijklIJKL ABCDEFG
  *
  * If we want to upgrade this decoder, it is possible to use the high 4-bit of the first
  * element for versioning, because it is guaraneed to be zero for the current version.
  */
  function decodePath(bytes memory body) external pure override returns (bytes memory) {
    uint16 i;
    uint16 length = (uint16(body.length) * 2)/ 3;
    bytes[] memory rets = new bytes[](length);
    for (i = 0; i < length; i++) {
      // unpack 12-bit middle endian
      uint16 offset = i / 2 * 3;
      uint8 low;
      uint8 high;
      if (i % 2 == 0) {
        low = uint8(body[offset]);
        high = uint8(body[offset + 1]) % 0x10; // low 4 bits of middle byte
      } else {
        low = uint8(body[offset + 2]);
        high = uint8(body[offset + 1]) / 0x10; // high 4 bits of middle byte
      }
      if (high == 0) {
        // SVG command: Accept only [A-Za-z] and ignore others 
        if ((low >=65 && low<=90) || (low >= 97 && low <= 122)) {
          rets[i] = abi.encodePacked(low);
        }
      } else {
        // SVG value: undo (value + 1024) + 0x100 
        uint16 value = uint16(high) * 0x100 + uint16(low) - 0x100;
        if (value >= 1024) {
          rets[i] = abi.encodePacked((value - 1024).toString(), " ");
        } else {
          rets[i] = abi.encodePacked("-", (1024 - value).toString(), " ");
        }
      }
    }
    while (rets.length > 1) {
      rets = merge(rets);
    }
    return rets[0];
  }
}