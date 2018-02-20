pragma solidity ^0.4.19;

/* Interface for creating a multisignature wallet */
contract MultiSigFactory{

	/* A general proposal that can be used for multiple functionality
	1 - To make a proposal for a new transaction
	2 - To make a proposal for adding a new owner
		In this case:
		subject would be the address of the new owner that is proposed
		value would be 0
		bytes would be 0
	*/
	struct Transaction {
		address destination;
		uint value;
		bytes data;
		bool executed;
	}
	//Different possible proposal purpose
	enum ProposalPurpose { AddOwner, RemoveOwner, ReplaceOwner}

	struct Proposal {
		address owner;
		ProposalPurpose purpose;
		bool executed;
	}
	
	mapping (uint => Transaction) public transactions;
	mapping (uint => Proposal) public proposals;
	//Initates a new transaction
	function initiateNewTransaction(address destination, uint value, bytes data) public returns (int transactionId);
	//Participant can accpet a tranaction based on the transaction ID
	function acceptTransaction(uint transactionId) public;
	//Participant can reject a tranaction based on the transaction ID
	function rejectTransaction(uint transactionId) public;
	//Initiate a proposal for an owner change. This could be ADD, REMOVE, or REPLACE
	function initiateProposal(address owner, ProposalPurpose purpose) public;
	//Owners can accept the proposal based on the propsal ID
	function acceptProposal(uint proposalId) public;
	//Owners can reject the proposal based on the propsal ID
	function rejectProposal(uint proposalId) public;
}