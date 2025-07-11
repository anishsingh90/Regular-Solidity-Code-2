// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EtherWallet{
    //mapping to track the transaction
    mapping(address => uint) private balances;

    //event for the log the transaction
    event deposited(address indexed user, uint256 amount);
    event withdrawal(address indexed user, uint256 amount);

    //Function to deposite
    function deposite() external payable{
        require(msg.value > 0, "Amount can must be greater than zero");
        balances[msg.sender] += msg.value;
        emit deposited(msg.sender, msg.value);
    }

    //Function to Withdrawal
    function withdraw(uint256 amount) external{
        require(amount > 0, "Withdrawal amount must be greater than 0");
        require(balances[msg.sender] >= amount, "Insufficient balance");

        //update balance before sending to prevent reentrancy
        balances[msg.sender] -= amount;

        //send ether to user
        (bool send, ) = msg.sender.call{value: amount}(" ");
        require(send, "Failed to send Ether");

        emit withdrawal(msg.sender, amount);
    }

    //Return the balance of the calling user
    function getBalance() external view returns(uint256){
        return balances[msg.sender];
    }

    //Return the contract's total Ether balance
    function getContractBalance() external view returns (uint256){
        return address(this).balance;
    }
}