// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/utils/Strings.sol";

pragma solidity ^0.8.6;

library SVGPathDecoder {
  using Strings for uint16;

  function decodePath(bytes memory body) internal pure returns (bytes memory) {
    bytes memory ret;
    uint16 i;
    uint16 length = (uint16(body.length) * 2)/ 3;
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
          ret = abi.encodePacked(ret, low);
        }
      } else {
        // SVG value: undo (value + 1024) + 0x100 
        uint16 value = uint16(high) * 0x100 + uint16(low) - 0x100;
        if (value >= 1024) {
          ret = abi.encodePacked(ret, (value - 1024).toString(), " ");
        } else {
          ret = abi.encodePacked(ret, "-", (1024 - value).toString(), " ");
        }
      }
    }
    return ret;
  }
}