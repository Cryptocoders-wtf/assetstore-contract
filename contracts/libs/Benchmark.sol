// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

contract Benchmark {
  uint256 counter;

  function measure() external returns(string memory) {
    counter += 1;
    return "Hello World";
  }
}