// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract etherTransfer{
    //Mapping to track user balamces
    mapping (address=> uint) private balances;

    //Events to log transactions
    event deposited(address indexed user, uint256 amount);
    event withdrawalMade(address indexed user, uint256 amount);

    function deposit() external payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        balances[msg.sender] += msg.value;
        emit deposited(msg.sender, msg.value);
    }

    //Withdrawal Function
    function withdraw(uint256 amount) public {
        require(amount > 0, "Withdrawal amount must be greater than 0");
        require(balances[msg.sender] >= amount, "Insufficient Balances");

        balances[msg.sender] -= amount;
        

        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Failed to send Ether");

        emit withdrawalMade(msg.sender, amount);
    }

    //Return the balance of the calling user
    function getBalance() external view returns(uint256){
        return balances[msg.sender];
    }

    //Return to contract's total Ether balance
    function getContractBalance() external view returns(uint256){
        return address(this).balance;
    }
}