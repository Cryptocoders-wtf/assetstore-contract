// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/utils/Strings.sol";
import "../interfaces/IPathDecoder.sol";

pragma solidity ^0.8.6;

contract SVGPathDecoder2 is IPathDecoder {
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
    uint256 length = (uint256(body.length) * 2)/ 3;
    bytes memory retAll;
    uint256 limit = 10;
    // get a rough square root
    while(limit * limit < length) {
      limit += 2;
    }

    uint256 j;
    uint256 i;
    uint8 low;
    uint8 high;
    uint256 offset;
    uint256 end;
    uint256 digits;
    for (j = 0; j < length; j+=limit) {
      bytes memory ret;
      end = (j+limit < length) ? j+limit:length;
      for (i = j; i < end; i++) {
        // unpack 12-bit middle endian
        offset = i / 2 * 3;
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
            ret = abi.encodePacked(ret, low);
          }
        } else {
          // SVG value: undo (value + 1024) + 0x100 
          uint256 value = uint256(high) * 0x100 + uint256(low) - 0x100;
          if (value >= 1024) {
            value = value - 1024;
          } else {
            ret = abi.encodePacked(ret, "-");
            value = 1024 - value;
          }

          // inline version of vlaue.toString() optimized for 4-digit case
          if (value < 100) {
            digits = (value < 10) ? 1 : 2;
          } else {
            digits = (value < 1000) ? 3 : 4;
          }
          bytes memory buffer = new bytes(digits);
          buffer[0] = "0"; // handle case for value=0
          while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
          }
          ret = abi.encodePacked(ret, buffer, " ");
        }
      }
      retAll = abi.encodePacked(retAll, ret);
    }
    return retAll;
  }
}