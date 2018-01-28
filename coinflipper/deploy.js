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
	uint bet;
	uint[] private variables = new uint[](2);

	enum GameState { betOpen, betWaiting, betClosed}
	GameState public coinFlip;

	function coinFlipper() public{
		coinFlip = GameState.betOpen;
	}

	function offerBet(uint _rand) public payable {
		require(coinFlip == GameState.betOpen);
		bet = msg.value;
		coinFlip = GameState.betWaiting;
		parties[0] = msg.sender;
		variables[0] = _rand;
	}

	function meetBet(uint _rand) public payable {
		require(coinFlip == GameState.betWaiting);
		require(msg.value >= bet);
		coinFlip = GameState.betClosed;
		parties[1] = msg.sender;
		variables[1] = _rand;
	}

	function flipCoin() public{
		if(((variables[0] * block.number) + (variables[1] * block.timestamp))% 2 == 0){
			parties[0].send(this.balance);
		} else {
			parties[1].send(this.balance);
		}
		coinFlip = GameState.betOpen;
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
	offerBet : function(contract, party, amount, rand){
		contract.methods.offerBet(rand).send({from:party, value:amount})
		.then(receipt => console.log(receipt));
	},

	//Calls the contract meetBet function
	meetBet : function(contract, party, amount, rand){
		contract.methods.meetBet(rand).send({from:party, value:amount})
		.then(receipt => console.log(receipt));
	},

	//Flips the coin
	flipCoin: function(contract){
		contract.methods.flipCoin().send({from:web3.eth.defaultAccount})
		.then(console.log);
	}
}