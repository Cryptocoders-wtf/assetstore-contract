// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import { IMessageBox, Message } from './interfaces/IMessageBox.sol';

contract MessageBox is Ownable, IMessageBox {
  mapping(address => Message[]) messages;
  mapping(address => uint256) counts;

	function send(address _to, Message memory _message) external override returns (uint256) {
    require(msg.sender == _message.sender);
    _message.isRead = false;
    _message.isDeleted = false;
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

	function markRead(address _to, uint256 _index, bool _isRead) external override returns (Message memory) {
    Message storage message = messages[_to][_index];
    message.isRead = _isRead;
    return message;
  }

	function markDeleted(address _to, uint256 _index, bool _isDeleted) external override returns (Message memory) {
    Message storage message = messages[_to][_index];
    message.isDeleted = _isDeleted;
    return message;
  }
}