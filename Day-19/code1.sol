// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleBank{
    //Owner of the contract
    address public  owner;

    //Mapping to track account balances
    mapping (address => uint256) private balances;

    //Event to log doposits
    event Deposit(address indexed account, uint256 amount);

    //Event to log withdrawals
    event Withdrawal(address indexed account, uint256 amount);

    //Constructor sets the owner
    constructor(){
        owner = msg.sender;
    }

    //Function to deposit ETH into the account
    function deposit() public payable {
        require(msg.value > 0, "Deposit amount be greater than 0");
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    //Function to withdraw ETH from the account
    function withdraw(uint256 amount) public {
        require(amount > 0, "Withdrawal amount must be greater than 0");
        require(balances[msg.sender] >= amount, "Insufficiet balance");

        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdrawal(msg.sender, amount);
    }

    //Function to check the balance of the caller
    function getBalance() public view returns(uint256){
        return balances[msg.sender];
    }

    //Function to check the balance of any address(only owner)
    function getBalanceOf(address account) public view onlyOwner returns(uint256){
        return balances[account];
    }

    //Modifier to restrict access to the owner only
    modifier onlyOwner(){
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }
}