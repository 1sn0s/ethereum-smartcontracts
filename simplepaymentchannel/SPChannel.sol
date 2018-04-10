pragma solidity ^0.4.20;

/**
 * The SPChannel contract is a simplified payment channel between two parties
 * It will only persist across one set of payments
 * Only the second party can close the channel
 */
contract SPChannel {
	address public payer;
	address public receiver;
	uint256 public channelEndTime;

	function SPChannel (address _receiver, uint256 endTIme)
		public 
		payable 
	{
		payer = msg.sender;
		receiver = _receiver;
		channelEndTime = now + endTime;
	}

	///public functions

	//Close the payment channel
	function close(uint256 amount,	bytes signature) 
		public
		returns(bool res)
	{		
		require(msg.sender == receiver);
		require(isValidSignature(amount, signature));

		receiver.transfer(amount);
		//Destruct the channel ? or switch off ?
	}

	//Extend the remaining time of the payment channel
	function extendChannelLife(uint256 endTIme) 
		public
		returns(bool res)
	{
		require(msg.sender == payer);
		require(endTime > now);

		channelEndTime = endTIme;
		return true;
	}

	function reclaim() public {
		require(msg.sender == payer);		
	}

	///Private functions

	function isValidSignature(uint256 amount, bytes signature) 
		private
		returns(bool isSignatureValid)
	{
		//Note: signature message = amount + channel address
		//Construct the message and get the public address
		//Verify address

		bytes32 message = keccak256(amount, this);
		return getSigner(signature, message) == payer;
	}

	function getSigner(bytes32 signature, bytes32 message) 
		private
		returns(address signerAddress)
	{
		uint8 v;
		bytes32 r;
		bytes32 s;

		(v, r, s) = getSignatureSplitUp(signature);
		return ecrecover(message, v, r, s);
	}

	function getSignatureSplitUp(bytes32 signature)
		private
		returns(uint8 v, bytes32 r, bytes32 s)
	{
		uint8 v;
		bytes32 r;
		bytes32 s;

		assembly {
			r := mload(add(signature, 32))
			s := mload(add(signature, 64))
			v := byte(0, mload(add(signature, 96)))
		}

		return (v, r, s);
	}
	
}
