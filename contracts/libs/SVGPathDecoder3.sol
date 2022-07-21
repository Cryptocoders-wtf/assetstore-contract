// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/utils/Strings.sol";
import "../interfaces/IPathDecoder.sol";

pragma solidity ^0.8.6;

contract SVGPathDecoder3 is IPathDecoder {
  function digitsOf(uint16 _value) internal pure returns(uint256) {
    if (_value == 0) {
        return 0;
    }
    uint256 digits;
    while (_value != 0) {
        digits++;
        _value /= 10;
    }
    return digits;
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
    uint256 count; // required memory size
    uint16 i;
    uint16 length = (uint16(body.length) * 2)/ 3;

    // In the first loop, just measure the required memory size
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
          count += 1;
        }
      } else {
        // SVG value: undo (value + 1024) + 0x100 
        uint16 value = uint16(high) * 0x100 + uint16(low) - 0x100;
        if (value >= 1024) {
          count += digitsOf(value - 1024) + 1;
        } else {
          count += digitsOf(1024 - value) + 2;
        }
      }
    }

    bytes memory ret = new bytes(count);
    uint256 index;
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
          ret[offset] = bytes1(low);
          offset += 1;
        }
      } else {
        // SVG value: undo (value + 1024) + 0x100 
        uint16 value = uint16(high) * 0x100 + uint16(low) - 0x100;
        if (value >= 1024) {
          value -= 1024;
        } else {
          ret[index] = "-";
          index += 1;
          value = 1024 - value;
        }
        if (value == 0) {
          ret[index] = "0";
          index += 1;
        } else {
          uint256 digits = digitsOf(value);
          uint256 temp = digits;
          while (value != 0) {
            temp -= 1;
            ret[index + temp] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
          }
          index += digits;
        }
        ret[index] = " ";
        index += 1;
      }
      require(index <= count, "BUGBUG: index <= count");
    }
    require(index == count, "BUGBUG: index != count");

    return ret;
  }
}