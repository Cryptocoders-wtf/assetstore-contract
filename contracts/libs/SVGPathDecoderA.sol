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
//    uint256 length = ((body.length) * 2)/ 3;
    assembly{
      let bodyMemory := add(body, 0x20)
      let length := div(mul(mload(body), 2), 3)
      ret := mload(0x40)
      let retMemory := add(ret, 0x20)
      let retLength := 0
      let data
      for {let i := 0} lt(i, length){i := add(i,1)} {
        if eq(mod(i,16),0) {
          data := mload(bodyMemory)
          bodyMemory := add(bodyMemory, 24)
        }
        let low
        let high
        switch mod(i,2)
        case 0{
          low := and(shr(248, data), 0xff)
          high := and(shr(240, data), 0x0f)
        }
        default{
          low := and(shr(232, data), 0xff)
          high := and(shr(244, data), 0x0f)
          data := shl(24, data)
        }
        
        switch high
        case 0{
          if and( gt(low, 64), lt(low, 91)){
            mstore(add(retMemory,retLength), shl(248,low))
            retLength := add(retLength, 1)
          }
          if and( gt(low, 96), lt(low, 123)){
            mstore(add(retMemory,retLength), shl(248,low))
            retLength := add(retLength, 1)
          }
        }
        default{
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
            cmd := or(shl(8,cmd), add(48, div(mod(value,100), 10)))
            lenCmd := add(1, lenCmd)
            value := mod(value,10)
          }
          cmd := or(shl(8,cmd), add(48, value))
          lenCmd := add(1, lenCmd)

          cmd := or(shl(8,cmd), 32)
          lenCmd := add(lenCmd, 1)
          mstore(add(retMemory,retLength), shl(sub(256, mul(lenCmd,8)),cmd))
          retLength := add(retLength, lenCmd)
        }
      }
      mstore(ret, retLength)
      mstore(0x40, add(retMemory, retLength))
    }
    return ret;
  }

}