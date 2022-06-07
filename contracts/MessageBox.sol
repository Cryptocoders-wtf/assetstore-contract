// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import { IMessageBox, Message } from './interfaces/IMessageBox.sol';

contract MessageBox is IMessageBox {
  mapping(address => Message[]) messages;
  mapping(address => uint256) counts;

	function send(address _to, Message memory _message) external override returns (uint256) {
    require(msg.sender == _message.sender);
    Message[] storage queue = messages[_to];
    uint256 index = counts[_to];
    queue[index] = _message;
    counts[_to] = index + 1;
    return index;
  }

	function count(address _to) external view override returns (uint256) {
    return counts[_to];
  }

	function get(address _to, uint256 _index) external view override returns (Message memory) {
    return messages[_to][_index];
  }
}