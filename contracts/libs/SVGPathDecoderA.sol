// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/utils/Strings.sol";
import "../interfaces/IPathDecoder.sol";

contract SVGPathDecoderA is IPathDecoder {
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
//  function decodePath(bytes memory body) external pure override returns (bytes memory) {
  function decodePath(bytes memory body) external pure override returns (bytes memory) {
    bytes memory ret;
//    uint16 i;
    uint256 length = ((body.length) * 2)/ 3;
    assembly{
      let bodyMemory := add(body, 0x20)
      let length := div(mul(mload(body), 2), 3)
      ret := mload(0x40)
      let retMomory := add(ret, 0x20)
      for {let i := 0} lt(i, length){i := add(i,1)} {
        let offset := mul(div(i, 2), 3)
        let low
        let hight
        switch eq(mod(i,2), 0)
        case 1{
          low := mload(add(bodyMemory, offset))
          high := and(shr(248, low),0x0f)
          low := shr(252, low)
        }
        default{
          high := mload(add(bodyMemory, add(offset, 1)))
          low := and(shr(248, high),0xff)
          high := shr(25)
        }
        
      }
    }
    for (i = 0; i < length; i++) {
      // unpack 12-bit middle endian      // unpack 12-bit middle endian
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

        
        assembly{
          let cmd := 0
          let lenCmd := 0
          // SVG value: undo (value + 1024) + 0x100 
          let value := sub(add(shl(8, high), low), 0x0100)
          switch lt(value, 1024)
          case 0{
            value := sub(value,1024)
          }
          default{
            // add "-"
            cmd := 45
            lenCmd := 1
            value := sub(1024,value)
          }
          if gt(value,999){
            cmd := or(shl(8,cmd), add(48, div(value, 1000)))
            lenCmd := add(1, lenCmd)
          }
          if gt(value,99){
            cmd := or(shl(8,cmd), add(48, div(mod(value,1000), 100)))
            lenCmd := add(1, lenCmd)
          }
          if gt(value,9){
            value := mod(mod(value,1000), 100)
            cmd := or(shl(8,cmd), add(48, div(value, 10)))
            lenCmd := add(1, lenCmd)
            value := mod(value,10)
          }
          cmd := or(shl(8,cmd), add(48, value))
          lenCmd := add(1, lenCmd)

          cmd := or(shl(8,cmd), 32)
          lenCmd := add(lenCmd, 1)
          mstore(add(ret,add(0x20, mload(ret))), shl(sub(256, mul(lenCmd,8)),cmd))
          mstore(ret, add(mload(ret), lenCmd))
        }
      }        
    }
    return ret;
  }

}