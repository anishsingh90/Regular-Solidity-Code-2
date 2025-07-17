// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Escrow {
    // Roles
    address public buyer;
    address public seller;
    address public immutable arbitrator;

    // Escrow state
    enum State { AWAITING_PAYMENT, FUNDS_DEPOSITED, DISPUTED, COMPLETED, REFUNDED }
    State public currentState;

    uint256 public amount;
    bool public buyerConfirmed;
    bool public sellerRefundRequested;

    // Events
    event Deposited(address indexed buyer, uint256 amount);
    event Released(address indexed seller, uint256 amount);
    event Refunded(address indexed buyer, uint256 amount);
    event DisputeRaised(address indexed by);
    event DisputeResolved(address indexed arbitrator, address beneficiary);

    // Modifiers
    modifier onlyBuyer() {
        require(msg.sender == buyer, "Only buyer can call this");
        _;
    }

    modifier onlySeller() {
        require(msg.sender == seller, "Only seller can call this");
        _;
    }

    modifier onlyArbitrator() {
        require(msg.sender == arbitrator, "Only arbitrator can call this");
        _;
    }

    modifier inState(State _state) {
        require(currentState == _state, "Invalid state");
        _;
    }

    constructor(address _seller, address _arbitrator) {
        buyer = msg.sender;
        seller = _seller;
        arbitrator = _arbitrator;
        currentState = State.AWAITING_PAYMENT;
    }

    // Buyer deposits funds into escrow
    function deposit() external payable onlyBuyer inState(State.AWAITING_PAYMENT) {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        amount = msg.value;
        currentState = State.FUNDS_DEPOSITED;
        emit Deposited(msg.sender, msg.value);
    }

    // Buyer confirms receipt and release funds to seller
function releaseToSeller() external onlyBuyer inState(State.FUNDS_DEPOSITED) {
    buyerConfirmed = true;
    _completeTransaction(payable(seller));
}

    // Seller can request refund (e.g., if buyer didn't confirm)
    function requestRefund() external onlySeller inState(State.FUNDS_DEPOSITED) {
        sellerRefundRequested = true;
        _refundBuyer();
    }

    // Either party can raise a dispute
    function raiseDispute() external inState(State.FUNDS_DEPOSITED) {
        require(msg.sender == buyer || msg.sender == seller, "Unauthorized");
        currentState = State.DISPUTED;
        emit DisputeRaised(msg.sender);
    }

    // Arbitrator resolves dispute
    function resolveDispute(address beneficiary) external onlyArbitrator inState(State.DISPUTED) {
        currentState = State.COMPLETED;
        payable(beneficiary).transfer(amount);
        emit DisputeResolved(msg.sender, beneficiary);
    }

    // Internal function to complete the transaction
    function _completeTransaction(address payable _to) internal {
        require(currentState == State.FUNDS_DEPOSITED, "Invalid state");
        currentState = State.COMPLETED;
        payable(_to).transfer(amount);
        emit Released(_to, amount);
    }

    // Internal function to refund the buyer
    function _refundBuyer() internal {
        require(currentState == State.FUNDS_DEPOSITED, "Invalid state");
        currentState = State.REFUNDED;
        payable(buyer).transfer(amount);
        emit Refunded(buyer, amount);
    }
}