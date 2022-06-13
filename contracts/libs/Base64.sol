// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.6;

library Base64 {
  bytes constant private base64map = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";

  function _encode3(uint256 _b0, uint256 _b1, uint256 _b2) private pure
      returns (bytes1 ch0, bytes1 ch1, bytes1 ch2, bytes1 ch3) {
    uint256 n = (_b0 << 16) | (_b1 << 8) | _b2;
    ch0 = base64map[(n >> 18) & 0x3f];
    ch1 = base64map[(n >> 12) & 0x3f];
    ch2 = base64map[(n >>  6) & 0x3f];
    ch3 = base64map[(n      ) & 0x3f];
  }

  function encode(string memory _str) external pure returns (string memory) {
    bytes memory src = bytes(_str);
    uint256 extra = src.length % 3;
    bytes memory des = new bytes((src.length + 2) / 3 * 4 - ((3 - extra) % 3));

    uint256 i = 0;
    uint256 j = 0;
    for (; i + 3 <= src.length; i += 3) {
      (des[j], des[j+1], des[j+2], des[j+3]) = _encode3(
        uint8(src[i]), uint8(src[i+1]), uint8(src[i+2])
      );
      j += 4;
    }

    if (extra > 0) {
      uint8 first = uint8(src[src.length - extra]);
      if (extra == 1) {
        (des[j], des[j+1], , ) = _encode3(first, 0, 0);
      } else {
        uint8 second = uint8(src[src.length - 1]);
        (des[j], des[j+1], des[j+2], ) = _encode3(first, second, 0);
      }
    }

    return string(des);
  }
}