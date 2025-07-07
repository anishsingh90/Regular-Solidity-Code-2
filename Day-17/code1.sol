// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LendingBorrowing{
    struct Loan{
        address lender;
        address borrower;
        uint256 principal;
        uint256 interestRate;
        uint256 startTimestamp;
        uint256 duration;
        bool isRepaid;
        bool isWithdrawn;
    }

    uint256 public loanIdCounter;
    mapping(uint256=> Loan) public loans;

    event LoanOffered(uint256 indexed loanId, address indexed lender, uint256 principal, uint256 interestRate, uint256 duration);
    event LoanTaken(uint256 indexed loanId, address indexed borrower);
    event LoanRepaid(uint256 indexed loanId, address indexed borrower, uint256 amount);
    event LoanWithdrawn(uint256 indexed loanId, address indexed lender, uint256 amount);

    //Lender offers a loan by locking Ether in the contract
    function offerLoan(uint256 interestRateBps, uint256 durationSecs) external payable returns(uint256){
        require(msg.value > 0, "No funds sent");
        require(durationSecs > 0, "Duration must be positive");


        loanIdCounter++;
        loans[loanIdCounter] = Loan({
            lender: msg.sender,
            borrower: address(0),
            principal: msg.value,
            interestRate: interestRateBps,
            startTimestamp: 0,
            duration: durationSecs,
            isRepaid: false,
            isWithdrawn: false
        });

        emit LoanOffered(loanIdCounter, msg.sender, msg.value, interestRateBps, durationSecs);
        return loanIdCounter;
    }

    //Borrower takes a loan
    function takeLoan(uint256 loanId) external{
        Loan storage loan = loans[loanId];
        require(loan.lender != address(0), "Loan does not exist");
        require(loan.borrower == address(0), "Loan already taken");
        require(!loan.isWithdrawn, "Already withdrawn");


        loan.borrower = msg.sender;
        loan.startTimestamp = block.timestamp;

        payable(msg.sender).transfer(loan.principal);

        emit LoanTaken(loanId, msg.sender);
    }


    //Borrower repays loan with interest
    function repayLoan(uint256 loanId) external payable {
        Loan storage loan = loans[loanId];
        require(msg.sender == loan.borrower, "Not borrower");
        require(!loan.isRepaid, "Already repaid");
        require(loan.startTimestamp > 0, "Loan not started");


        uint256 totalDue = getTotalRepayAmount(loanId);
        require(msg.value >= totalDue, "Insufficient repayment");

       loan.isRepaid = true;

       emit LoanRepaid(loanId, msg.sender, msg.value);

       //Refund any excess payment
       if(msg.value > totalDue){
        payable(msg.sender).transfer(msg.value - totalDue);
       } 
    }

    //Lender withdraws repaid funds
    function withdraws(uint256 loanId) external {
        Loan storage loan = loans[loanId];
        require(msg.sender == loan.lender, "Not lender");
        require(loan.isRepaid, "Not repaid yet");
        require(!loan.isWithdrawn, "Already withdrawn");

        loan.isWithdrawn = true;
        uint256 amount = getTotalRepayAmount(loanId);

        payable(msg.sender).transfer(amount);

        emit LoanWithdrawn(loanId, msg.sender, amount);
    }

    //Utility: Get amount to repay
    function getTotalRepayAmount(uint256 loanId) public view returns(uint256){
        Loan storage loan = loans[loanId];
        require(loan.lender != address(0), "Loan does not exist");
        require(loan.startTimestamp > 0, "Loan not started");
        
        
        //Simple interest: principal * rate_elapsed / (1 year)
        uint256 timeElapsed = block.timestamp > loan.startTimestamp + loan.duration
        ? loan.duration
        : block.timestamp - loan.startTimestamp;

        uint256 interest = loan.principal * loan.interestRate * timeElapsed / 1e4 / 365 days;
        return loan.principal + interest;
    }

    //Emergency: lender can withdraw funds if loan not taken
    function cancelLoan(uint256 loanId) external {
        Loan storage loan = loans[loanId];
        require(msg.sender == loan.lender, "Not lender");
        require(loan.borrower == address(0), "Loan already taken");
        require(!loan.isWithdrawn, "Already withdrawn");

        loan.isWithdrawn = true;

        payable(msg.sender).transfer(loan.principal);
    }
}