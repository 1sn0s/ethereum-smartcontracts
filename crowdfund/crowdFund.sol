pragma solidity ^0.4.19;

contract crowdFund{
	mapping(address=>uint) contribution;
	uint goal;
	uint public current;

	enum FundStatus {stopped, inProgress, goalAchieved, goalNotAchieved, refundInProgress, Completed}
	FundStatus _fundStatus;

	function crowdFund(){
		_fundStatus = FundStatus.inProgress;
	}

	modifier _fundStatus(FundStatus _status){
		require(_status == _fundStatus);
		_;
	}

	function contribute() public _fundStatus(FundStatus.inProgress){
		//TODO: Check if value exceeds. Then refund rest.
		contribution[msg.sender] = msg.value;
	}
}