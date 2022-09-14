// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import { IAssetStore, IAssetStoreEx } from './interfaces/IAssetStore.sol';
import { IAssetProvider } from './interfaces/IAssetProvider.sol';
import { Trigonometry } from './libs/trigonometry.sol';

contract SplatterProvider {
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
    return ret;
  }  
}