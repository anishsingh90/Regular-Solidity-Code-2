// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MonthlySubscription {
    address public owner;
    uint256 public subscriptionFee; // in wei (e.g. 0.01 ETH = 10**16 wei)
    uint256 public period = 30 days;

    struct Subscriber {
        uint256 nextPaymentTime;
        bool active;
    }

    mapping(address => Subscriber) public subscribers;

    event Subscribed(address indexed user, uint256 nextPaymentTime);
    event PaymentReceived(address indexed user, uint256 amount, uint256 nextPaymentTime);
    event Cancelled(address indexed user);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(uint256 _subscriptionFee) {
        owner = msg.sender;
        subscriptionFee = _subscriptionFee;
    }

    function subscribe() external payable {
        require(!subscribers[msg.sender].active, "Already subscribed");
        require(msg.value == subscriptionFee, "Incorrect payment");
        subscribers[msg.sender] = Subscriber({
            nextPaymentTime: block.timestamp + period,
            active: true
        });
        emit Subscribed(msg.sender, block.timestamp + period);
    }

    function pay() external payable {
        require(subscribers[msg.sender].active, "Not subscribed");
        require(block.timestamp >= subscribers[msg.sender].nextPaymentTime, "Payment not due yet");
        require(msg.value == subscriptionFee, "Incorrect payment");

        subscribers[msg.sender].nextPaymentTime += period;
        emit PaymentReceived(msg.sender, msg.value, subscribers[msg.sender].nextPaymentTime);
    }

    function cancel() external {
        require(subscribers[msg.sender].active, "Not subscribed");
        subscribers[msg.sender].active = false;
        emit Cancelled(msg.sender);
    }

    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    // Optional: check if user is active and up to date
    function isActive(address user) external view returns (bool) {
        return subscribers[user].active && block.timestamp < subscribers[user].nextPaymentTime;
    }
}