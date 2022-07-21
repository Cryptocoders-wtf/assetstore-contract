// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/utils/Strings.sol";
import "../interfaces/IPathDecoder.sol";

pragma solidity ^0.8.6;

contract SVGPathDecoder3 is IPathDecoder {
  function digitsOf(uint256 _value) internal pure returns(uint256) {
    if (_value < 10) {
      return 1;
    }
    if (_value < 100) {
      return 2;
    }
    if (_value < 1000) {
      return 3;
    }
    return 4;
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
    uint256 index;
    uint16 i;
    uint16 length = (uint16(body.length) * 2)/ 3;
    uint8 low;
    uint8 high;
    uint256 offset;
    uint256 value;

    // In the first loop, just measure the required memory size
    for (i = 0; i < length; i++) {
      // unpack 12-bit middle endian
      offset = i / 2 * 3;
      if (i % 2 == 0) {
        low = uint8(body[offset]);
        high = uint8(body[offset + 1]) % 0x10; // low 4 bits of middle byte
      } else {
        low = uint8(body[offset + 2]);
        high = uint8(body[offset + 1]) / 0x10; // high 4 bits of middle byte
      }
      if (high > 0) {
        // SVG value: undo (value + 1024) + 0x100 
        value = uint256(high) * 0x100 + uint256(low) - 0x100;
        if (value >= 1024) {
          value = value - 1024;
        } else {
          index += 1;
          value = 1024 - value;
        }
        if (value < 100) {
          index += (value < 10) ? 1 : 2;
        } else {
          index += (value < 1000) ? 3 : 4;
        }
      }
    }

    uint count = index + length;
    bytes memory ret = new bytes(count);
    index = 0;
    uint256 digits;
    uint256 temp;

    // In the second loop, we actually fill values
    for (i = 0; i < length; i++) {
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
          ret[index] = bytes1(low);
        } else {
          ret[index] = " ";
        }
        index += 1;
      } else {
        // SVG value: undo (value + 1024) + 0x100 
        value = uint256(high) * 0x100 + uint256(low) - 0x100;
        if (value >= 1024) {
          value = value - 1024;
        } else {
          ret[index] = "-";
          index += 1;
          value = 1024 - value;
        }
        digits = digitsOf(value);
        if (value == 0) {
          ret[index] = "0";
        } else {
          temp = digits;
          while (value != 0) {
            temp -= 1;
            ret[index + temp] = bytes1(uint8(48 + value % 10));
            value /= 10;
          }
        }
        ret[index + digits] = " ";
        index += digits + 1;
      }
    }
    require(index == count, "BUGBUG: index == count");

    return ret;
  }
}