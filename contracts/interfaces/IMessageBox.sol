// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

struct Message {
	address messenger; // messager contract
	uint256 id;        // message id
	address sender;    // sender
	string message;    // text representation
	string url;        // icon
}

interface IMessageBox {
	function send(address _to, Message memory _message) external returns (uint256);
	function count(address _to) external returns (uint256);
	function get(address _to, uint256 _index) external returns (Message memory);
}

interface ISpamFilter {
	function isSpam(address _to, Message memory _message) external returns (bool);
	function reportSpan(address _to, Message memory _message) external;
}