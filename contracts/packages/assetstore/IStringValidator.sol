// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface IStringValidator {
  function validate(bytes memory str) external pure returns (bool);
  function sanitizeJson(string memory _str) external pure returns(bytes memory);
}
