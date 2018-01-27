var Web3 = require("Web3");
var web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
web3.eth.getAccounts().then((accounts)=>{
	web3.eth.defaultAccount = accounts[0];
	console.log("Default Account", web3.eth.defaultAccount);
	//To be used from the console
	module.exports.web3   = web3;
	module.exports.party1 = accounts[1];
	module.exports.party2 = accounts[2];
})

var solc = require("solc");
var src = `pragma solidity ^0.4.19;
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
	
}`;

//Helper functions to play around in the console
//Saves a lot of time. Don't want to add any framework
module.exports = {
	//Prepares the contract deploy transaction
	deployCoinFlipper : function(){

		var compiled 			= solc.compile(src);
		//console.log("compiled", compiled);
		var compiledContract	= compiled.contracts[":coinFlipper"];
		var abi 				= JSON.parse(compiledContract.interface);
		var coinFlipper 		= new web3.eth.Contract(abi, '', {
			from: web3.eth.defaultAccount
		});

		coinFlipper.options = {
			jsonInterface: abi,
			from : web3.eth.defaultAccount,
			data : '0x' + compiledContract.bytecode,
			gas : 4700000,
			gasPrice : 10
		};

		var deployed = coinFlipper.deploy(coinFlipper.options);
		return deployed;
	},

	//Not sure why, but you have to set provider for a contract separately.
	//TODO : Check why
	setProvider : (contract) => {contract.setProvider(web3.currentProvider);},

	//Calls the contract offerBet function
	offerBet : function(contract, party, amount){
		contract.methods.offerBet(amount).send({from:party})
		.then(receipt => console.log(receipt));
	},

	//Calls the contract meetBet function
	meetBet : function(contract, party, amount){
		contract.methods.meetBet(amount).send({from:party})
		.then(receipt => console.log(receipt));
	},
}