// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import { IMessageBox } from './interfaces/IMessageBox.sol';

contract MessageBox is Ownable, IMessageBox {
  mapping(uint256 => mapping(uint256 => Message)) messages;
  mapping(uint256 => uint256) numberOfMessages; // for each room
  mapping(uint256 => mapping(address => bool)) accessRights;
  mapping(address => mapping(address => uint256)) roomsForTwo;
  mapping(address => mapping(uint256 => uint256)) joinedRooms;
  mapping(address => uint256) joinedRoomCount;
  uint256 nextRoom = 1; // 0 also means no such a room

  constructor() {
  }

  function _joinRoom(address _address, uint256 roomIndex) internal returns (uint256) {
    require(_address != address(0), "_joinRoom: invalid address");
    uint256 index = joinedRoomCount[_address];
    require(joinedRooms[_address][index] == 0);
    joinedRooms[_address][index] = roomIndex;
    joinedRoomCount[_address] = index + 1;
    accessRights[roomIndex][_address] = true;
    return index;
  } 

  // @notice return the room index for two addresses, creating it if necessary.
  function _getRoomIndexForTwo(address _to, address _from) internal returns (uint256) {
    require(_to != address(0), "_joinRoom: invalid address for _to");
    require(_from != address(0), "_joinRoom: invalid address for _from");
    uint256 roomIndex = roomsForTwo[_to][_from];
    if (roomIndex > 0) {
      return roomIndex;
    }
    roomIndex = nextRoom++;
    roomsForTwo[_to][_from] = roomIndex;
    roomsForTwo[_from][_to] = roomIndex;
    _joinRoom(_to, roomIndex);
    _joinRoom(_from, roomIndex);
    return roomIndex;
  }

  function _addMessage(uint256 roomIndex, Message memory _message) internal returns (uint256) {
    require(roomIndex > 0);
    uint256 messageIndex = numberOfMessages[roomIndex];
    messages[roomIndex][messageIndex] = _message;
    numberOfMessages[roomIndex] = messageIndex + 1;
    return messageIndex;
  }

	function _sendMessage(address _to, string memory _text, string memory _imageURL, address _app, uint256 _messageId) internal returns (uint256) {
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

    uint256 roomIndex = _getRoomIndexForTwo(msg.sender, _to);
    uint messageIndex = _addMessage(roomIndex, message);
    emit MessageReceived(msg.sender, _to, messageIndex);
    return messageIndex;
  }

	function sendAppMessage(address _to, string memory _text, string memory _imageURL, address _app, uint256 _messageId) external override returns (uint256) {
    return _sendMessage(_to, _text, _imageURL, _app, _messageId);
  }

	function sendMessage(address _to, string memory _text) external override returns (uint256) {
    return _sendMessage(_to, _text, "", address(0), 0);
  }

	function roomCount() external view override returns (uint256) {
    require(msg.sender != address(0), "roomCount: missing msg.sender");
    return joinedRoomCount[msg.sender];
  }

	function messageCount(uint256 _roomIndex) external view override returns (uint256) {
    require(msg.sender != address(0), "roomCount: missing msg.sender");
    require(accessRights[_roomIndex][msg.sender]);
    require(_roomIndex > 0, "roomCount: Invalid _roomIndex");
    return numberOfMessages[_roomIndex];
  }

	function getMessage(uint256 _roomIndex, uint256 _messageIndex) external view override returns (Message memory) {
    require(accessRights[_roomIndex][msg.sender]);
    require(_roomIndex > 0, "getMessage: invalid _roomIndex");
    return messages[_roomIndex][_messageIndex];
  }
}