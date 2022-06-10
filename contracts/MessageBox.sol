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
  uint256 nextRoomId = 1; // 0 also means no such a room

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
    roomId = nextRoomId++;
    roomsForTwo[_from][_to] = roomId;
    roomsForTwo[_to][_from] = roomId;
    _joinRoom(_from, roomId);
    _joinRoom(_to, roomId);
    members[roomId] = [_from, _to];
    emit RoomCreated(roomId);
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
    emit MessageReceived(roomId, messageIndex);
    return messageIndex;
  }

	function sendAppMessage(address _to, string memory _text, string memory _imageURL, address _app, uint256 _messageId) external override returns (uint256) {
    require(msg.sender != address(0), "sendAppMessage: missing msg.sender");
    return _sendMessage(_to, _text, _imageURL, _app, _messageId);
  }

	function sendMessage(address _to, string memory _text) external override returns (uint256) {
    require(msg.sender != address(0), "sendMessage: missing msg.sender");
    return _sendMessage(_to, _text, "", address(0), 0);
  }

	function roomCount() external view override returns (uint256) {
    require(msg.sender != address(0), "roomCount: missing msg.sender");
    return joinedRoomCount[msg.sender];
  }

  function getRoomId(uint256 _roomIndex) external view override returns (uint256) {
    require(msg.sender != address(0), "getRoomId: missing msg.sender");
    require(_roomIndex < joinedRoomCount[msg.sender], "getRoomId: invalid _roomIndex");
    return joinedRooms[msg.sender][_roomIndex];    
  }

	function getMembers(uint256 _roomId) external view override returns (address[] memory) {
    require(msg.sender != address(0), "getMembers: missing msg.sender");
    require(_roomId > 0 && _roomId < nextRoomId, "getMembers: Invalid _roomId");
    require(accessRights[_roomId][msg.sender], "getMembers: no access right");
    return members[_roomId];
  }

	function messageCount(uint256 _roomId) external view override returns (uint256) {
    require(msg.sender != address(0), "messageCount: missing msg.sender");
    require(_roomId > 0 && _roomId < nextRoomId, "messageCount: Invalid _roomId");
    require(accessRights[_roomId][msg.sender], "messageCount: no access right");
    return numberOfMessages[_roomId];
  }

	function getMessage(uint256 _roomId, uint256 _messageIndex) external view override returns (Message memory) {
    require(msg.sender != address(0), "getMessage: missing msg.sender");
    require(_roomId > 0 && _roomId < nextRoomId, "getMessage: Invalid _roomId");
    require(accessRights[_roomId][msg.sender], "getMessage: no access right");
    return messages[_roomId][_messageIndex];
  }
}