pragma solidity ^0.4.19;

contract crowdFund{
	address public beneficiary;
	address private _owner;
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
		_owner		= msg.sender;
	}

	modifier fundStatus(FundStatus _status){
		require(_status == _fundStatus);
		_;
	}

	modifier acceptFund(FundStatus _status, uint _now){
		require(_status == FundStatus.inProgress && _now <= deadline);
		_;
	}

	modifier isOwner(_address){
		require(_owner == _address);
		_;
	}

	function contribute() public payable acceptFund(FundStatus.inProgress, now){
		//TODO: Check if value exceeds. Then refund rest.
		contribution[msg.sender] += msg.value;
		fundAchieved += msg.value;
		if(fundAchieved >= goal){
			_fundStatus = FundStatus.goalAchieved;
		}
	}

	//Close the fund.
	function closeFund() public returns(uint fundStatus){
		if(_isOwner(msg.sender)){
			_fundStatus = FundStatus.stopped;
		}
		if(fundAchieved >= goal){
			_fundStatus = FundStatus.goalAchieved;
		} else {
			_fundStatus = FundStatus.goalNotAchieved;
		}
		returns _fundStatus;
	}

	function _isOwner(address _address) private returns(bool isOwner){
		return (_address == _owner);
	}

	//Checking if the dealine has passed.
	//TODO: Check if this condition is safe/secure
	function _isPastDeadLine() private returns(bool isPastDealine){
		return now >= deadline;
	}


}