pragma solidity ^0.4.19;

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

}