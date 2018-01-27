pragma solidity ^0.4.19;
contract coinFlipper{
	mapping(uint=>address) parties;
	mapping(address=>uint) bets;

	enum GameState { betOpen, betWaiting, betClosed}
	GameState public coinFlip;

	function coinFlipper() public{
		coinFlip = GameState.betOpen;
	}

	function offerBet(uint _amount) public payable {
		require(coinFlip == GameState.betOpen);
		coinFlip = GameState.betWaiting;
		parties[0] = msg.sender;
		bets[msg.sender] = _amount;
	}

	function meetBet(uint _amount) public payable {
		require(coinFlip == GameState.betWaiting);
		require(_amount >= bets[parties[0]]);
		coinFlip = GameState.betClosed;
		parties[1] = msg.sender;
		bets[msg.sender] = _amount;
	}
	
}