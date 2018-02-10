var Web3 = require("Web3");
var web3 = new Web3(new Web3.providers.WebsocketProvider("ws://localhost:8545"));
var IPFS = require('ipfs-mini');
const ipfs = new IPFS({host: "ipfs.infura.io", port:5001, protocol:"https"});

web3.eth.getAccounts().then((accounts)=>{
	web3.eth.defaultAccount = accounts[0];
	console.log("Default Account", web3.eth.defaultAccount);
	//To be used from the console
	module.exports.web3   = web3;
	module.exports.party1 = accounts[1];
	module.exports.party2 = accounts[2];
});

//ipfs.add("helloworld", (err, result)=>console.log("result", result));

var solc = require("solc");
var src = `	pragma solidity ^0.4.19;
	contract coinFlipper{
		mapping(uint=>address) parties;
		uint bet;
		string public latestResultHash;
		uint[] private variables = new uint[](2);
		address private winner;

		enum GameState { betOpen, betWaiting, betClosed}
		GameState private coinFlip;

		event GameResult(address winner, uint winnings);		

		function coinFlipper() public{
			coinFlip = GameState.betOpen;
		}

		modifier gameOn(GameState _state){
			require(coinFlip == _state);
			_;
		}

		function offerBet(uint _rand) public payable 
		gameOn(GameState.betOpen) {		
			bet = msg.value;
			coinFlip = GameState.betWaiting;
			parties[0] = msg.sender;
			variables[0] = _rand;
		}

		function meetBet(uint _rand) public payable 
		gameOn(GameState.betWaiting){
			require(msg.value >= bet);
			coinFlip = GameState.betClosed;
			parties[1] = msg.sender;
			variables[1] = _rand;
		}

		function flipCoin() public 
		gameOn(GameState.betClosed){			
			uint winnings = this.balance;
			if(((variables[0] * block.number) + (variables[1] * block.timestamp))% 2 == 0){
				parties[0].send(this.balance);
				winner = parties[0];
			} else {
				parties[1].send(this.balance);
				winner = parties[1];
			}
			GameResult(winner, winnings);
		}

		function setResult(string storageHash) public
		gameOn(GameState.betClosed){
			require(winner == msg.sender);
			latestResultHash = storageHash;
			coinFlip = GameState.betOpen;
		}
	}`;

var getResult = function(eventData){
	let txHash = eventData.transactionHash;
	let winnerAddress = eventData.returnValues["winner"];
	let winnings = eventData.returnValues["winnings"];
	let result = "\ntxHash: " + txHash
				+ "\n" + "Winner: " + winnerAddress
				+ "\n" + "Winnings: " + winnings;
	return result;
}

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

	startEventListener : (contract) => {
		contract.events.GameResult({}, function(err, event){
			if(err) console.log;
		})
		.on('data', function(event){
			console.log("event data", event);
			if(event.returnValues){
				let result = getResult(event);
				ipfs.add(result, (err, result)=>{
					//console.log("ipfs write result", result);
					//resultHash = result;
					contract.methods.setResult(result).send({from:event.returnValues["winner"]});
				});
			}
		});
	},

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
	},

	checkResult: function(contract){
		contract.methods.latestResultHash().send({from:web3.eth.defaultAccount})
		.then(resultHash=>{
			ipfs.cat(resultHash, (err, result)=>{
				console.log("Result", result);
			});
		});
	}
}