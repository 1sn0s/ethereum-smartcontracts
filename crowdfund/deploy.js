var Web3 = require("Web3");
var web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
web3.eth.getAccounts().then((accounts)=>{
	web3.eth.defaultAccount = accounts[0];
	console.log("Default Account", web3.eth.defaultAccount);
	//To be used from the console
	module.exports.web3   = web3;
	module.exports.accounts = accounts;
	module.exports.beneficiary = accounts[8];
})

var solc = require("solc");
var src = `pragma solidity ^0.4.19;

contract crowdFund{
	address public beneficiary;
	address private _owner;
	uint public goal;
	uint public deadline;
	uint public fundAchieved;
	mapping(address=>uint) private contribution;

	enum FundStatus {Fund, End, Goal, Refund, Done}
	FundStatus _fundStatus;

	function crowdFund(address _beneficiary, uint _goal, uint _deadline) public{
		beneficiary = _beneficiary;
		goal 		= _goal;
		deadline 	= _deadline;
		_fundStatus = FundStatus.Fund;
		_owner		= msg.sender;
	}

	modifier fundStatus(FundStatus _status){
		require(_status == _fundStatus);
		_;
	}

	modifier acceptFund(FundStatus _status, uint _now){
		require(_status == FundStatus.Fund && _now <= deadline);
		_;
	}

	function contribute() public payable acceptFund(FundStatus.Fund, now){
		//TODO: Check if value exceeds. Then refund rest.
		contribution[msg.sender] += msg.value;
		fundAchieved += msg.value;
	}

	//Close the fund.
	function endFunding() public returns(uint status){
		require(_owner == msg.sender);
		_fundStatus = FundStatus.End;
		if(_isGoalAchieved()){
			_fundStatus = FundStatus.Goal;
		}

		return uint(_fundStatus);
	}

	function startRefund() public fundStatus(FundStatus.End) {
		require(_owner == msg.sender);
		_fundStatus = FundStatus.Refund;
	}

	function refund() public fundStatus(FundStatus.Refund) {
		require(contribution[msg.sender] > 0);
		uint _contribution = contribution[msg.sender];
		contribution[msg.sender] = 0;
		msg.sender.transfer(_contribution);
	}

	function transferBeneficiary() public fundStatus(FundStatus.Goal) {
		require(_owner == msg.sender);
		_fundStatus = FundStatus.Done;
		beneficiary.transfer(this.balance);
	}

	function _isOwner(address _address) private view returns(bool isOwner){
		return (_address == _owner);
	}

	//Checking if the dealine has passed.
	//TODO: Check if this condition is safe/secure
	function _hasEnded() private view returns(bool isPastDealine){
		return now >= deadline;
	}

	function _isGoalAchieved() private view  returns(bool isGoalAchieved){
		return fundAchieved >= goal;
	}

}`;

//Helper functions to play around in the console
//Saves a lot of time. Don't want to add any framework
module.exports = {
	//Prepares the contract deploy transaction
	deployTx : function(beneficiary){

		var compiled 			= solc.compile(src);
		//console.log("compiled", compiled);
		var compiledContract	= compiled.contracts[":crowdFund"];
		var abi 				= JSON.parse(compiledContract.interface);
		var crowdFund	 		= new web3.eth.Contract(abi);
		//console.log("crowdFund", crowdFund);
		console.log("beneficiary", beneficiary);
		crowdFund.options = {
			jsonInterface: abi,
			data : '0x' + compiledContract.bytecode,
			gas : 4700000,
			gasPrice : 10,
			arguments : [beneficiary, 100, 1617518931]
		};

		var deployed = crowdFund.deploy(crowdFund.options);
		return deployed;
	},

	//Not sure why, but you have to set provider for a contract separately.
	//TODO : Check why
	setProvider : (contract) => {contract.setProvider(web3.currentProvider);}
}