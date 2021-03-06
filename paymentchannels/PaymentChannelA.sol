pragma solidity ^0.4.21;

/* One way payment channel 
   Payer doesnot have to escrow the whole payment in the begining
   No preset channel life
   Receiver can verify and escrow payment from payer
   Once receiver starts a withdraw channel will be closed
   Receiver can withdraw escrowed amounts even after channel closing
   Payer can withdraw amounts not escrowed by receiver
*/

import "../math/SafeMath.sol";

contract PaymentChannelA {
	address payer;
	address receiver;
	uint256 escrowed;
	bool isChannelClosed;

	function PaymentChannelA(address _receiver)
		public
	{
		payer = msg.sender;
		receiver = _receiver;
		isChannelClosed = false;
	}

	//Withdraw funds for receiver
	function withdraw(uint256 amount, bytes signature) 
		public
		returns(bool res)
	{		
		require(msg.sender == receiver);
		require(amount <= this.balance);
		require(!isChannelClosed || (amount <= escrowed));
		require(isValidSignature(amount, signature));

		isChannelClosed = true;
		escrowed = escrowed.sub(amount) < 0 ? 0 : escrowed.sub(amount);
		receiver.transfer(amount);
		return true;
	}

	//Verify and escrow a payment received from payer without withdrawing
	function escrowPayment(uint256 amount, bytes signature) 
		public
		returns(bool res)
	{
		require(!isChannelClosed);
		require(msg.sender == receiver);
		require(amount <= this.balance);
		require(isValidSignature(amount, signature));
		//Escrow it here
		escrowed = amount;
		return true;
	}

	//For payer to reduce channel funds
	function reduceChannelBalance(int256 amount) 
		public
		returns(bool res)
	{
		require(msg.sender == payer);
		require(amount <= (this.balance - escrowed));

		payer.transfer(amount);
		return true;		
	}

	//For payer to increase the channel funds
	function increaseChannelBalance(uint256 amount)
		public
		payable
		returns(bool res)
	{
		require(isChannelClosed == false);
		require(msg.sender == payer);
		return true;
	}

	function openChannel() public returns(bool res)
	{
		require(msg.sender == payer);
		isChannelClosed = false;
		return true;
	}

	///Private functions

	function isValidSignature(uint256 amount, bytes signature) 
		private
		returns(bool isSignatureValid)
	{
		//Note: signature message = amount + channel address
		//Construct the message and get the public address
		//Verify address
		bytes memory prefix = "\x19Ethereum Signed Message:\n32";

		bytes32 message = keccak256(prefix, keccak256(amount, this));
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