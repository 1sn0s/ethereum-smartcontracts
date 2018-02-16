pragma solidity ^0.4.19;
/*
Multi signature contract
*/
contract MultiSigContract{
	uint public sigLimit;
	mapping(address=>bool) private _isOwner;
	address[] public ownersList;

	function MultiSigContract(address[] ownersToSet, uint sigCount){
		require(ownersToSet.length <= sigCount && sigCount != 0);
		//The addresses should be sent in an increasing order
		//This is to avoid the duplicate check
		address _lastAddress = address(0);
		for(uint ownerIndex= 0; ownerIndex < ownersToSet.length; ownerIndex++){
			require(ownersToSet[ownerIndex] > _lastAddress);			
			_isOwner[ownersToSet[ownerIndex]] = true;
			_lastAddress = ownersToSet[ownerIndex];
		}
		ownersList = ownersToSet;
		sigLimit = sigCount;
	}

	function execute(string sigv, string sigR, string sigS, 
		address destination, uint value, string data){
		//EIP 191
	}
}