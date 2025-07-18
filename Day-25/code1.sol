// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TransactionHistory{
    //Structure to store transaction details
    struct Transaction{
        uint256 timestamp;
        uint256 value;
        address from;
    }

    //Mapping from address to their transaction history
    mapping (address => Transaction[]) private _transactionHistory;

    //Event emitted when a new transaction is recoreded
    event TransactionRecorded(
        address indexed to,
        address indexed from,
        uint256 value,
        uint256 timestamp
    );

    //Function to get transaction count for an address
    function getTransactionCount(address account) public view returns(uint256){
        return _transactionHistory[account].length;
    }

    //function to get transaction details by index
    function getTransaction(address account, uint256 index) public view returns(uint256 timestamp, uint256 value, address from){
        require(index < _transactionHistory[account].length, "Transaction index out of bounds");
        Transaction memory transaction = _transactionHistory[account][index];

        return (transaction.timestamp, transaction.value, transaction.from);
    }

    //Function to get all transaction for an address
    function getAllTransactions(address account) public view returns(Transaction[] memory){
        return _transactionHistory[account];
    }

    //fallback function to record incoming transaction
    receive() external payable { 
        _recordTransaction(msg.sender, msg.value);
    }

    //Internal function to record transactions
    function _recordTransaction(address to, uint256 value) internal{
        require(value > 0, "Transaction value must be greater than 0");

        Transaction memory newTransaction = Transaction({
            timestamp : block.timestamp,
            value : value,
            from : msg.sender
        });

        _transactionHistory[to].push(newTransaction);
        emit TransactionRecorded(to, msg.sender, value, block.timestamp);
    }

    //Function to manually record a transaction(for testing or other purposes)
    function _recordTransaction(address to) external payable {
        require(msg.value > 0, "Transaction value must be greater than 0");

        _recordTransaction(to, msg.value);
    }
}