pragma solidity ^0.4.19;

contract crowdFund{
	address public beneficiary;
	uint public goal;
	uint public deadline;
	uint public fundAchieved;
	mapping(address=>uint) contribution;

	enum FundStatus {stopped, inProgress, goalAchieved, goalNotAchieved, refundInProgress, Completed}
	FundStatus _fundStatus;

	function crowdFund(address _beneficiary, uint _goal, uint _deadline){
		beneficiary = _beneficiary;
		goal 		= _goal;
		deadline 	= _deadline;
		_fundStatus = FundStatus.inProgress;
	}

	modifier _FundStatus(FundStatus _status){
		require(_status == _fundStatus);
		_;
	}

	modifier _AcceptFund(FundStatus _status, uint _now){
		require(_status == FundStatus.inProgress && _now <= deadline);
		_;
	}

	function contribute() public _AcceptFund(FundStatus.inProgress, now){
		//TODO: Check if value exceeds. Then refund rest.
		contribution[msg.sender] = msg.value;
	}
}