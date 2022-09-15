// SPDX-License-Identifier: MIT

/*
 * Pseudo Random genearation library.
 *
 * Created by Satoshi Nakajima (@snakajima)
 */

pragma solidity ^0.8.6;

library Randomizer {
  struct Seed {
    uint256 seed;
    uint256 value;
  }

  /**
   * Returns a seudo random number between 0 and _limit-1.
   * It also returns an updated seed.
   */
  function random(Seed memory _seed, uint256 _limit) internal pure returns (Seed memory seed, uint256 value) {
    seed = _seed;
    if (seed.value < _limit * 256) {
      seed.seed = uint256(keccak256(abi.encodePacked(seed.seed)));
      seed.value = seed.seed;
    }
    value = seed.value % _limit;
    seed.value /= _limit;
  }

  /**
   * Returns a randomized value based on the original value and ration (in percentage).
   * It also returns an updated seed. 
   */
  function randomize(Seed memory _seed, uint256 _value, uint256 _ratio) internal pure returns (Seed memory seed, uint256 value) {
    uint256 limit = _value * _ratio / 100;
    uint256 delta;
    (seed, delta) = random(_seed, limit * 2);
    value = _value - limit + delta;
  }
}