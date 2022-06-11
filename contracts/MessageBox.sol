// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import { IMessageBox } from './interfaces/IMessageBox.sol';

contract MessageBox is Ownable, IMessageBox {
  mapping(uint256 => mapping(uint256 => Message)) messages; // roomId => messageIndex => message
  mapping(uint256 => uint256) numberOfMessages; // roomId => messageCount
  mapping(uint256 => address[]) members; // roomId => [wallet]
  mapping(uint256 => mapping(address => bool)) accessRights; // roomId => hasRight
  mapping(bytes32 => uint256) roomsForMembers; // hash(addresses) => roomId
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
  function _getRoomIdForMembers(address[] memory addresses) internal returns (uint256) {
    require(msg.sender != address(0), "_getRoomIdForMembers: missing msg.sender");
    require(addresses.length > 0, "_getRoomIdForMembers: members is empty");
    uint i = 0;
    address member = addresses[0]; 
    bool hasMe = (member == msg.sender);
    for (i = 1; i < addresses.length; i++) {
      address nextMember = addresses[i]; 
      require(member < nextMember, "_getRoomIdForMembers: members is not sorted");
      member = nextMember;
      if (member == msg.sender) {
        hasMe = true;
      } 
    }
    require(hasMe, "_getRoomIdForMembers: members does not contain msg.sender");

    bytes32 key = keccak256(abi.encodePacked(addresses));
    uint256 roomId = roomsForMembers[key];
    if (roomId > 0) {
      return roomId;
    }
    roomId = nextRoomId++;
    roomsForMembers[key] = roomId;
    for (i = 0; i< addresses.length; i++) {
      _joinRoom(addresses[i], roomId);
    }
    members[roomId] = addresses;
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

	function _sendMessage(uint256 _roomId, string memory _text, string memory _imageURL, address _app, uint256 _messageId) internal returns (uint256) {
    Message memory message;
    message.sender = msg.sender;
    message.text = _text;
    message.imageURL = _imageURL;
    message.app = _app;
    message.messageId = _messageId;
    message.timestamp = block.timestamp;

    uint messageIndex = _addMessage(_roomId, message);
    emit MessageReceived(_roomId, msg.sender, messageIndex);
    return messageIndex;
  }

	function sendMessage(address[] memory _members, string memory _text) external override returns (uint256) {
    uint256 roomId = _getRoomIdForMembers(_members);
    return _sendMessage(roomId, _text, "", address(0), 0);
  }

	function sendAppMessage(address[] memory _members, string memory _text, string memory _imageURL, address _app, uint256 _messageId) external override returns (uint256) {
    uint256 roomId = _getRoomIdForMembers(_members);
    return _sendMessage(roomId, _text, _imageURL, _app, _messageId);
  }

  modifier onlyRoomMember(uint256 _roomId) {
    require(msg.sender != address(0), "onlyRoomMember: missing msg.sender");
    require(_roomId > 0 && _roomId < nextRoomId, "onlyRoomMember: Invalid _roomId");
    require(accessRights[_roomId][msg.sender], "onlyRoomMember: no access right");
    _;
  }

  function sendMessageToRoom(uint256 _roomId, string memory _text) external override onlyRoomMember(_roomId) returns (uint256) {
    require(msg.sender != address(0), "sendMessageToRoom: missing msg.sender");
    return _sendMessage(_roomId, _text, "", address(0), 0);
  }

	function sendAppMessageToRoom(uint256 _roomId, string memory _text, string memory _imageURL, address _app, uint256 _messageId) external override onlyRoomMember(_roomId) returns (uint256) {
    require(msg.sender != address(0), "sendAppMessageToRoom: missing msg.sender");
    return _sendMessage(_roomId, _text, _imageURL, _app, _messageId);
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

  function getRoomInfo(uint256 _roomId) external view override onlyRoomMember(_roomId) returns (RoomInfo memory) {
    RoomInfo memory roomInfo;
    roomInfo.messageCount = numberOfMessages[_roomId];
    require(roomInfo.messageCount > 0);
    roomInfo.timestamp = messages[_roomId][roomInfo.messageCount - 1].timestamp;
    roomInfo.members = members[_roomId];
    return roomInfo;
  }

	function getMessage(uint256 _roomId, uint256 _messageIndex) external view override onlyRoomMember(_roomId) returns (Message memory) {
    return messages[_roomId][_messageIndex];
  }
}