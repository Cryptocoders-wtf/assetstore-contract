// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

/*
 * @notice
 * The "app" optionaly specifies the associated messenge application, 
 * which offers additional capabilities such as encryption and attachments. 
*/
struct Message {
	address sender;    // sender
	address receiver;  // receiver
	string text;       // text representation
	string imageURL;   // image representation (optional)
	address app;       // the contract address of message application (optional)
	uint256 messageId; // message id (optional, specific to the app)
	uint256 timestamp; // block.timestamp
	bool isRead;       // receiver's state
	bool isDeleted;    // receiver's state
}

/*
 * @notice
 * This ia the message box interface, which allows messenger applications to exchange
 * on-chain messages. 
*/
interface IMessageBox {
	function send(address _to, string memory _text) external returns (uint256);
	function sendAppMessage(address _to, string memory _text, string memory _imageURL, address _app, uint256 _messageId) external returns (uint256);
	function count() external returns (uint256);
	function get(uint256 _index) external returns (Message memory);
	function markRead(uint256 _index, bool _isRead) external returns (Message memory);
	function markDeleted(uint256 _index, bool _isDeleted) external returns (Message memory);
	event MessageReceived(address _from, address _to, uint256 _index);
	event MessageRead(address _from, address _to, uint256 _index, bool _isRead);
	event MessageDeleted(address _from, address _to, uint256 _index, bool _isDeleted);
}

interface ISpamFilter {
	function isSpam(address _to, Message memory _message) external returns (bool);
	function reportSpam(address _to, Message memory _message) external;
}