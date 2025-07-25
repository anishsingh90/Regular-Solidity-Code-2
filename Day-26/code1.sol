// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EtherLending {
    address public owner;
    uint public totalLiquidity;
    uint public constant INTEREST_RATE = 5; // 5% annual interest
    uint public constant SECONDS_PER_YEAR = 31536000; // 365 days
    
    struct Loan {
        address borrower;
        uint amount;
        uint interestRate;
        uint startTime;
        bool repaid;
    }
    
    mapping(address => uint) public lenders;
    mapping(address => Loan[]) public borrowers;
    
    event Deposited(address indexed lender, uint amount);
    event Withdrawn(address indexed lender, uint amount);
    event Borrowed(address indexed borrower, uint amount);
    event Repaid(address indexed borrower, uint amount, uint interest);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    // Lenders deposit ETH to the pool
    function deposit() external payable {
        require(msg.value > 0, "Must deposit more than 0 ETH");
        lenders[msg.sender] += msg.value;
        totalLiquidity += msg.value;
        emit Deposited(msg.sender, msg.value);
    }
    
    // Lenders withdraw their ETH plus earned interest
    function withdraw(uint amount) external {
        require(amount <= lenders[msg.sender], "Insufficient balance");
        lenders[msg.sender] -= amount;
        totalLiquidity -= amount;
        
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Failed to send ETH");
        emit Withdrawn(msg.sender, amount);
    }
    
    // Borrowers take out loans
    function borrow(uint amount) external {
        require(amount <= totalLiquidity, "Insufficient liquidity");
        require(amount > 0, "Must borrow more than 0 ETH");
        
        Loan memory newLoan = Loan({
            borrower: msg.sender,
            amount: amount,
            interestRate: INTEREST_RATE,
            startTime: block.timestamp,
            repaid: false
        });
        
        borrowers[msg.sender].push(newLoan);
        totalLiquidity -= amount;
        
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Failed to send ETH");
        emit Borrowed(msg.sender, amount);
    }
    
    // Borrowers repay their loans with interest
    function repay(uint loanIndex) external payable {
        require(loanIndex < borrowers[msg.sender].length, "Invalid loan index");
        Loan storage loan = borrowers[msg.sender][loanIndex];
        require(!loan.repaid, "Loan already repaid");
        
        uint timeElapsed = block.timestamp - loan.startTime;
        uint interest = (loan.amount * loan.interestRate * timeElapsed) / (SECONDS_PER_YEAR * 100);
        uint totalRepayment = loan.amount + interest;
        
        require(msg.value >= totalRepayment, "Insufficient repayment amount");
        
        loan.repaid = true;
        totalLiquidity += totalRepayment;
        
        // Refund any excess payment
        if (msg.value > totalRepayment) {
            uint refund = msg.value - totalRepayment;
            (bool sent, ) = msg.sender.call{value: refund}("");
            require(sent, "Failed to refund excess ETH");
        }
        
        emit Repaid(msg.sender, loan.amount, interest);
    }
    
    // Get details of a specific loan
    function getLoan(address borrower, uint index) external view returns (
        uint amount,
        uint interestRate,
        uint startTime,
        bool repaid
    ) {
        require(index < borrowers[borrower].length, "Invalid loan index");
        Loan storage loan = borrowers[borrower][index];
        return (
            loan.amount,
            loan.interestRate,
            loan.startTime,
            loan.repaid
        );
    }
    
    // Get total number of loans for a borrower
    function getLoanCount(address borrower) external view returns (uint) {
        return borrowers[borrower].length;
    }
    
    // Emergency function to recover ETH (owner only)
    function recoverETH(uint amount) external onlyOwner {
        require(amount <= address(this).balance, "Insufficient contract balance");
        (bool sent, ) = owner.call{value: amount}("");
        require(sent, "Failed to send ETH");
    }
}