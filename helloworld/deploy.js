var Web3 = require("Web3");
var web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
web3.eth.getAccounts().then(accounts => {
	web3.eth.defaultAccount = accounts[0];
	console.log("web3.eth.defaultAccount", web3.eth.defaultAccount);
	contractDeploy();
});
var solc = require("solc");

function contractDeploy(){
	var source = `contract helloworldContract {
		function displayMessage () public constant returns(string) {
			return "hello world";
		}
		
	}`;

	var compiled 		= solc.compile(source);
	//console.log("compiled", compiled);
	var escontract 		= compiled.contracts[":helloworldContract"];
	var abi 			= JSON.parse(escontract.interface);
	var firstContract 	= new web3.eth.Contract(abi);

	firstContract.options = {
		jsonInterface: abi,
		from : web3.eth.defaultAccount,
		data : '0x' + escontract.bytecode,
		gas : 4700000,
		gasPrice : 10
	};

	var callDisplayMessageOnContract = contractInstance => {
		contractInstance.methods.displayMessage().call()
		.then( result => { console.log("message", result);});
	};

	firstContract.deploy(firstContract.options)
	.send({
		from: web3.eth.defaultAccount,
		gas: 4700000,
		gasPrice : 10
	})
	.on('error', function(error){console.log(error);})
	.on('transactionHash', function(transactionHash){console.log(transactionHash);})
	.on('receipt', function(receipt){
	   console.log("contract address", receipt.contractAddress);
	})
	.then(callDisplayMessageOnContract);
}