// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import { IMessageBox } from './interfaces/IMessageBox.sol';

contract MessageBox is Ownable, IMessageBox {
  mapping(uint256 => mapping(uint256 => Message)) messages; // roomId => messageIndex => message
  mapping(uint256 => uint256) numberOfMessages; // roomId => messageCount
  mapping(uint256 => address[]) members; // roomId => [wallet]
  mapping(uint256 => mapping(address => bool)) accessRights; // roomId => hasRight
  mapping(address => mapping(address => uint256)) roomsForTwo; // wallet => wallet => roomId
  mapping(address => mapping(uint256 => uint256)) joinedRooms; // wallet => roomIndex => roomId
  mapping(address => uint256) joinedRoomCount; // wallet => roomCount
  uint256 nextRoom = 1; // 0 also means no such a room

  constructor() {
  }

  function _joinRoom(address _address, uint256 roomId) internal returns (uint256) {
    require(_address != address(0), "_joinRoom: invalid address");
    uint256 index = joinedRoomCount[_address];
    require(joinedRooms[_address][index] == 0, "_joinRoom: already joined");
    joinedRooms[_address][index] = roomId;
    joinedRoomCount[_address] = index + 1;
    accessRights[roomId][_address] = true;
    return index;
  } 

  // @notice return the room index for two addresses, creating it if necessary.
  function _getRoomIdForTwo(address _from, address _to) internal returns (uint256) {
    require(_from != address(0), "_joinRoom: invalid address for _from");
    require(_to != address(0), "_joinRoom: invalid address for _to");
    uint256 roomId = roomsForTwo[_to][_from];
    if (roomId > 0) {
      return roomId;
    }
    roomId = nextRoom++;
    roomsForTwo[_from][_to] = roomId;
    roomsForTwo[_to][_from] = roomId;
    _joinRoom(_from, roomId);
    _joinRoom(_to, roomId);
    members[roomId] = [_from, _to];
    return roomId;
  }

  function _addMessage(uint256 roomId, Message memory _message) internal returns (uint256) {
    require(roomId > 0);
    uint256 messageIndex = numberOfMessages[roomId];
    messages[roomId][messageIndex] = _message;
    numberOfMessages[roomId] = messageIndex + 1;
    return messageIndex;
  }

	function _sendMessage(address _to, string memory _text, string memory _imageURL, address _app, uint256 _messageId) internal returns (uint256) {
    address _from = msg.sender;
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

    uint256 roomId = _getRoomIdForTwo(_from, _to);
    // DEBUG CODE
    // require(accessRights[roomIndex][_from], "_sendMessage: no access right _from");
    // require(accessRights[roomIndex][_to], "_sendMessage: no access right _to");

    uint messageIndex = _addMessage(roomId, message);
    emit MessageReceived(_from, _to, messageIndex);
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

	function getMembers(uint256 _roomIndex) external view override returns (address[] memory) {
    require(msg.sender != address(0), "messageCount: missing msg.sender");
    require(_roomIndex < joinedRoomCount[msg.sender], "messageCount: invalid index");
    uint256 roomId = joinedRooms[msg.sender][_roomIndex];    
    require(roomId > 0, "messageCount: Invalid _roomIndex");
    require(accessRights[roomId][msg.sender], "messageCount: no access right");
    return members[roomId];
  }

	function messageCount(uint256 _roomIndex) external view override returns (uint256) {
    require(msg.sender != address(0), "messageCount: missing msg.sender");
    require(_roomIndex < joinedRoomCount[msg.sender], "messageCount: invalid index");
    uint256 roomId = joinedRooms[msg.sender][_roomIndex];    
    require(roomId > 0, "messageCount: Invalid _roomIndex");
    require(accessRights[roomId][msg.sender], "messageCount: no access right");
    return numberOfMessages[roomId];
  }

	function getMessage(uint256 _roomIndex, uint256 _messageIndex) external view override returns (Message memory) {
    require(msg.sender != address(0), "roomCount: missing msg.sender");
    require(_roomIndex < joinedRoomCount[msg.sender], "getMessage: invalid index");
    uint256 roomId = joinedRooms[msg.sender][_roomIndex];    
    require(roomId > 0, "getMessage: Invalid _roomIndex");
    require(accessRights[roomId][msg.sender], "getMessage: no access right");
    return messages[roomId][_messageIndex];
  }
}