// SPDX-License-Identifier: GPL-3.0 
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

//This controct was deployed and tested on REMIX IDE
//CrowdFunding Smart Contract Address = 0x9FCAB0975B210888f54bA816fcfe06dE491A0A66
//CrowdFundingToken Smart Contract Address = 0x5010FcC12AF6478ee19B4a582315681A1C12fA76

contract Crowdfunding {

    // custom ERC20 token
    IERC20 _token;
    uint DECIMALS = 18;
    // CrowdFunding Token Contract Address = 0x5010FcC12AF6478ee19B4a582315681A1C12fA76

    // events for state changes
    event FundsPledged(address sender, uint256 amount);
    event FundsRefunded(address receiver, uint256 amount);
    event GoalMet(uint256 goalAmount);

    // mapping to store pledges
    mapping (address => uint256) public pledges;

    // crowdfunding goal
    uint256 public goalAmount;
    address public contractAddress;

    constructor(address token) payable {
        _token = IERC20(token); //CrowdFundingToken Contract Address
        contractAddress = address(this);
        goalAmount = 100 * 10 ** DECIMALS; //100 CFT Tokens
    }

    // check if goal has been met
    function goalMet() public view returns (bool) {
        return (_token.balanceOf(contractAddress) == goalAmount);
    }

    // allow users to pledge funds
    function pledge(uint256 _amount) public payable {
        require(_token.balanceOf(contractAddress) + _amount <= goalAmount, "Cannot pledge more than goal amount");
        require(!goalMet(), "Goal Amount has already been met");

        // Check for Goal Met
        if(_token.balanceOf(contractAddress) + _amount == goalAmount){
            _token.transferFrom(msg.sender, contractAddress, _amount); 
            pledges[msg.sender] += _amount;     
            emit GoalMet(_token.balanceOf(contractAddress));
        }
        else{
           _token.transferFrom(msg.sender, contractAddress, _amount);
           pledges[msg.sender] += _amount; 
           emit FundsPledged(msg.sender, _amount);
        }
        
    }

    // allow users to get a refund if goal not met
    function refund() public {
        require(!goalMet(), "Goal has been met");
        require(pledges[msg.sender] > 0, "No funds to refund");
        _token.transfer(msg.sender, pledges[msg.sender]);
        pledges[msg.sender] = 0;
        emit FundsRefunded(msg.sender, pledges[msg.sender]);
    }

    function checkBalance(address _add) public view returns(uint256) {
        return _token.balanceOf(_add);
    }
}