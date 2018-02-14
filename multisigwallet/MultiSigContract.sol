pragma solidity ^0.4.19;

contract MultiSigContract{
	uint public sigLimit;
	mapping(address=>bool) private isOwner;
	address[] public ownersList;

	function MultiSigContract(address[] owners, uint sigLimit){

	}
}