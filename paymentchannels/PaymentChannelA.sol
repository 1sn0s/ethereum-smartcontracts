pragma solidity ^0.4.21;

/* One way payment channel 
   Payer doesnot have to escrow the whole payment in the begining
   No preset channel life
   Receiver can verify payment from payer and escrow amount in the contract for unlimited time
   Payer can withdraw amounts not escrowed by receiver
*/

contract PaymentChannelA {
	address payer;
	address receiver;
	//int256 escrowed;
	bool isChannelClosed;

	function PaymentChannelA(address _receiver)
		public
	{
		payer = msg.sender;
		receiver = _receiver;
		isChannelClosed = false;
	}

	//Close the payment channel
	function withdraw(uint256 amount, bytes signature) 
		public
		returns(bool res)
	{		
		require(msg.sender == receiver);
		require(amount <= this.balance);
		require(isValidSignature(amount, signature));

		//escrowed -= amount;
		receiver.transfer(amount);
		return true;
	}

	//Verify and escrow a payment received from payer without withdrawing
	function verifyPayment(uint256 amount, bytes signature) 
		public
		returns(bool res)
	{
		require(isChannelClosed == false);
		require(msg.sender == reciver);
		require(isValidSignature(amount, signature));
		//Escrow it here
		return true;
	}

	function reduceChannelBalance(int256 amount) 
		public
		return(bool res)
	{
		require(msg.sender == payer);
		require(amount <= this.balance);

		payer.transfer(amount);
		//isChannelClosed = true;
		return true;		
	}

	function increaseChannelBalance(uint256 amount)
		public
		payable
		return(bool res)
	{
		require(isChannelClosed == false);
		require(msg.sender == payer);
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