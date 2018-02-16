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
		address lastAddress = address(0);
		for(uint ownerIndex= 0; ownerIndex < ownersToSet.length; ownerIndex++){
			require(ownersToSet[ownerIndex] > _lastAddress);			
			_isOwner[ownersToSet[ownerIndex]] = true;
			lastAddress = ownersToSet[ownerIndex];
		}
		ownersList = ownersToSet;
		sigLimit = sigCount;
	}

	function execute(string[] sigV, string[] sigR, string[] sigS, 
		address destination, uint value, string data){
		//ERC 191
		require(sigv.length == sigLimit);
		require(sigR.lenght == sigS.length && sigR.length == sigV.length);

		byte32 txHash = keccak256(byte(0x19), byte(0), this, destination, value, data, nonce);

		address lastAddress = address(0);
		for(uint index; index<sigLimit; index++){
			address signer = ecrecover(txHash, sigV[index], sigR[index], sigS[index]);
			require(signer > lastAddress && _isOwner[signer]);
			lastAddress = signer;
		}

		nonce = nonce + 1;
		require(destination.call.value(value)(data));
	}

	function () payable {}
}