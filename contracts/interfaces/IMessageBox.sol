// SPDX-License-Identifier:  GPL-3.0

/*********************************
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░█████████░░█████████░░░ *
 * ░░░░░░██░░░████░░██░░░████░░░ *
 * ░░██████░░░████████░░░████░░░ *
 * ░░██░░██░░░████░░██░░░████░░░ *
 * ░░██░░██░░░████░░██░░░████░░░ *
 * ░░░░░░█████████░░█████████░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 *********************************/
 
pragma solidity ^0.8.6;

/*
 * @notice
 * This is the message box interface, which allows messenger applications to exchange
 * on-chain messages between wallets. 
*/
interface IMessageBox {
	/*
	* @notice
	* The "app" optionally specifies the associated message application, 
	* which offers additional capabilities such as encryption and attachments. 
	*/
	struct Message {
		address sender;    // sender
		string text;       // text representation
		string imageURL;   // image representation (optional)
		address app;       // the contract address of message application (optional)
		uint256 messageId; // app specific message id (optional)
		uint256 timestamp; // block.timestamp
	}

  /*
  * @notice timestamp is the timestamp of the most recent message. 
  */
	struct RoomInfo {
		uint256 messageCount;
    uint256 timestamp;
    address[] members;
	}

	function sendMessageToRoom(uint256 _roomId, string memory _text) external returns (uint256);
	function sendAppMessageToRoom(uint256 _roomId, string memory _text, string memory _imageURL, address _app, uint256 _messageId) external returns (uint256);
  // members must be sorted and includes msg.sender. It automatically creates a room, if necessary.
	function sendMessage(address[] memory _members, string memory _text) external returns (uint256);
  // members must be sorted and includes msg.sender. It automatically creates a room, if necessary.
	function sendAppMessage(address[] memory _members, string memory _text, string memory _imageURL, address _app, uint256 _messageId) external returns (uint256);
  // The number of chat rooms msg.sender belongs to.
	function roomCount() external view returns (uint256);
  // It maps a wallet-specific room index to a room id. 
	function getRoomId(uint256 _roomIndex) external view returns (uint256);
  function getRoomInfo(uint256 _roomId) external view returns (RoomInfo memory);
	function getMessage(uint256 _roomId, uint256 _messageIndex) external view returns (Message memory);

	event RoomCreated(uint256 roomId);
	event MessageReceived(uint256 roomId, address _sender, uint256 _messageIndex);
}

interface ISpamFilter {
	function isSpam(address _to, IMessageBox.Message memory _message) external returns (bool);
	function reportSpam(address _to, IMessageBox.Message memory _message) external;
}