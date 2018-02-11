/*
A dumb futures contract
_maker : 
address which makes the contract

_taker : 
address which takes the opposing side/accepts the contract

_agreementBasis : 
the contract that will be used to query the oracle

_agreementPrice :
cost of getting into the contract

_expiration : 
the expiration date of the contract.
A contract will be enforced at some point after the expiration date and will cease to exist afterwards 
if there are two parties involved the contract will be successfull
if no counterparty exisits, the funds will be returned to the _maker
Counter parties cannot enter into a contract after the expiration period.
*/

pragma solidity ^0.4.19;

A futures contract based on the contract string
contract DumbFuture{
	address public _maker;
	address public _taker;
	string public _agreementBasis;
	uint public _agreementPrice;
	uint32 public _expiration;

	function DumbFuture(string contract, uint price, uint32 expiry){
		_maker = msg.sender;
		_agreementBasis = contract;
		_agreementPrice = price;
		_expiration = expiry;
	}
}