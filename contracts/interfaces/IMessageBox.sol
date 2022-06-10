// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

/*
 * @notice
 * This ia the message box interface, which allows messenger applications to exchange
 * on-chain messages. 
*/
interface IMessageBox {
	/*
	* @notice
	* The "app" optionaly specifies the associated messenge application, 
	* which offers additional capabilities such as encryption and attachments. 
	*/
	struct Message {
		address sender;    // sender
		string text;       // text representation
		string imageURL;   // image representation (optional)
		address app;       // the contract address of message application (optional)
		uint256 messageId; // message id (optional, specific to the app)
		uint256 timestamp; // block.timestamp
	}
	struct RoomInfo {
		uint256 messageCount;
    uint256 timestamp;
    address[] members;
	}

	function sendMessageToRoom(uint256 _roomId, string memory _text) external returns (uint256);
	function sendAppMessageToRoom(uint256 _roomId, string memory _text, string memory _imageURL, address _app, uint256 _messageId) external returns (uint256);
	function sendMessage(address _to, string memory _text) external returns (uint256);
	function sendAppMessage(address _to, string memory _text, string memory _imageURL, address _app, uint256 _messageId) external returns (uint256);
	function roomCount() external view returns (uint256);
	function getRoomId(uint256 _roomIndex) external view returns (uint256);
  function getRoomInfo(uint256 _roomIndex) external view returns (RoomInfo memory);
	function getMessage(uint256 _roomId, uint256 _messageIndex) external view returns (Message memory);
	event RoomCreated(uint256 roomId);
	event MessageReceived(address _sender, uint256 roomId, uint256 _messageIndex);
}

interface ISpamFilter {
	function isSpam(address _to, IMessageBox.Message memory _message) external returns (bool);
	function reportSpam(address _to, IMessageBox.Message memory _message) external;
}