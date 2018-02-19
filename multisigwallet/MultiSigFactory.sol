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

	enum ProposalPurpose { AddOwner, RemoveOwner, ReplaceOwner};

	struct Proposal {
		address owner;
		ProposalPurpose purpose;
		bool executed;
	}
	
	mapping (uint => Transaction) public transactions;
	mapping (uint => Proposal) public proposals;

	function initiateNewTransaction(address destination, uint value, bytes data) returns (int transactionId);
	function acceptTransaction(uint transactionId);
	function rejectTransaction(uint transactionId);

	function initiateProposal(address owner);
	function acceptProposal(uint proposalId);
	function rejectProposal(uint proposalId);

}