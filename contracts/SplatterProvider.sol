// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import { IAssetStore, IAssetStoreEx } from './interfaces/IAssetStore.sol';
import { IAssetProvider } from './interfaces/IAssetProvider.sol';
import { Trigonometry } from './libs/trigonometry.sol';
import "@openzeppelin/contracts/utils/Strings.sol";

contract SplatterProvider {
  using Strings for uint16;
  struct Point {
    uint16 x;
    uint16 y;
    bool c;   // true:line, false:bezier
    uint16 r; // ratio (0 to 1)
  }
/*
export interface Point {
  x: number;
  y: number;
  c: boolean; // true:line, false:bezier
  r: number; // ratio (0 to 1)
}
export const pathFromPoints = (points: Point[]) => {
  const length = points.length;
  return points.reduce((path, cursor, index) => {
    const prev = points[(index + length - 1) % length];
    const next = points[(index + 1) % length];
    const sx = (cursor.x + prev.x) / 2;
    const sy = (cursor.y + prev.y) / 2;
    const head = index == 0 ? `M${sx},${sy},` : "";
    const ex = (cursor.x + next.x) / 2;
    const ey = (cursor.y + next.y) / 2;
    const last = `${ex},${ey}`;
    if (cursor.c) {
      return path + head + `L${cursor.x},${cursor.y},` + last;
    }
    const c1x = sx + cursor.r * (cursor.x - sx);
    const c1y = sy + cursor.r * (cursor.y - sy);
    const c2x = ex + cursor.r * (cursor.x - ex);
    const c2y = ey + cursor.r * (cursor.y - ey);
    return path + head + `C${c1x},${c1y},${c2x},${c2y},` + last;
  }, "");
};
*/

  function PathFromPoints(Point[] memory points) public pure returns(bytes memory) {
    bytes memory ret;
    uint256 length = points.length;
    for(uint256 i = 0; i < length; i++) {
      Point memory point = points[i];
      Point memory prev = points[(i + length - 1) % length];
      uint16 sx = (point.x + prev.x) / 2;
      uint16 sy = (point.y + prev.y) / 2;
      if (i == 0) {
        ret = abi.encodePacked("M", sx.toString(), ",", sy.toString());
      }
      if (point.c) {
        ret = abi.encodePacked(ret, "L", point.x.toString(), ",", point.y.toString());
      } else {
        Point memory next = points[(i + 1) % length];
        uint16 ex = (point.x + next.x) / 2;
        uint16 ey = (point.y + next.y) / 2;
        abi.encodePacked(ret, "C",
          (sx + point.r * (point.x - sx)).toString(), ",",
          (sy + point.r * (point.y - sy)).toString(), ",",
          (ex + point.r * (point.x - sx)).toString(), ",",
          (ey + point.r * (point.x - sx)).toString(), ",",
          ex.toString(), ",", ey.toString());
      }
    }
    return ret;
  }  
}