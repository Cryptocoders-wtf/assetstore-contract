// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import { IMessageBox } from './interfaces/IMessageBox.sol';

contract MessageBox is Ownable, IMessageBox {
  mapping(address => Message[]) messages;
  mapping(address => uint256) counts;

  constructor() {
  }

	function _sendAppMessage(address _to, string memory _text, string memory _imageURL, address _app, uint256 _messageId) internal returns (uint256) {
    Message memory message;
    message.sender = msg.sender;
    message.receiver = _to;
    message.text = _text;
    message.imageURL = _imageURL;
    message.app = _app;
    message.messageId = _messageId;
    message.isRead = false;
    message.isDeleted = false;
    message.timestamp = block.timestamp;
    Message[] storage queue = messages[_to];
    uint256 index = counts[_to];
    queue[index] = message;
    counts[_to] = index + 1;
    emit MessageReceived(msg.sender, _to, index);
    return index;
  }

	function sendAppMessage(address _to, string memory _text, string memory _imageURL, address _app, uint256 _messageId) external override returns (uint256) {
    return _sendAppMessage(_to, _text, _imageURL, _app, _messageId);
  }

	function send(address _to, string memory _text) external override returns (uint256) {
    return _sendAppMessage(_to, _text, "", address(0), 0);
  }

	function count() external view override returns (uint256) {
    return counts[msg.sender];
  }

	function get(uint256 _index) external view override returns (Message memory) {
    return messages[msg.sender][_index];
  }

	function markRead(uint256 _index, bool _isRead) external override returns (Message memory) {
    Message storage message = messages[msg.sender][_index];
    message.isRead = _isRead;
    emit MessageRead(message.sender, msg.sender, _index, _isRead);
    return message;
  }

	function markDeleted(uint256 _index, bool _isDeleted) external override returns (Message memory) {
    Message storage message = messages[msg.sender][_index];
    message.isDeleted = _isDeleted;
    emit MessageDeleted(message.sender, msg.sender, _index, _isDeleted);
    return message;
  }
}