// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title GasOptimizedSubscription
 * @dev Minimal gas cost subscription contract with monthly recurring payments
 */
contract Subscriptn {
    // Packed struct to save storage slots
    struct Subscription {
        address subscriber;
        uint96 amount;          // Max: 79.2M ETH (enough for subscriptions)
        uint32 startTime;       // Max: Year 2106 (Unix timestamp)
        uint32 lastPaymentTime; // Max: Year 2106
        uint32 interval;        // Monthly interval in seconds
        bool active;
    }

    // Storage layout optimization
    mapping(uint256 => Subscription) public subscriptions;
    mapping(address => uint256[]) public userSubscriptions;
    
    uint256 private nextSubscriptionId;
    address public owner;
    uint32 public constant MIN_INTERVAL = 28 days; // Minimum 28 days for monthly

    event SubscriptionCreated(
        uint256 indexed subscriptionId,
        address indexed subscriber,
        uint96 amount,
        uint32 interval
    );
    
    event PaymentProcessed(
        uint256 indexed subscriptionId,
        address indexed subscriber,
        uint96 amount,
        uint32 paymentTime
    );
    
    event SubscriptionCancelled(uint256 indexed subscriptionId);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier onlySubscriber(uint256 subscriptionId) {
        require(subscriptions[subscriptionId].subscriber == msg.sender, "Not subscriber");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev Create a new subscription with optimized parameters
     * @param amount Monthly payment amount in wei
     * @param interval Payment interval in seconds (must be >= MIN_INTERVAL)
     */
    function createSubscription(uint96 amount, uint32 interval) external payable returns (uint256) {
        require(amount > 0, "Invalid amount");
        require(interval >= MIN_INTERVAL, "Interval too short");
        require(msg.value == amount, "Incorrect payment");

        uint256 subscriptionId = nextSubscriptionId++;
        uint32 currentTime = uint32(block.timestamp);

        // Pack all data into single storage writes
        subscriptions[subscriptionId] = Subscription({
            subscriber: msg.sender,
            amount: amount,
            startTime: currentTime,
            lastPaymentTime: currentTime,
            interval: interval,
            active: true
        });

        userSubscriptions[msg.sender].push(subscriptionId);

        emit SubscriptionCreated(subscriptionId, msg.sender, amount, interval);
        return subscriptionId;
    }

    /**
     * @dev Process payment for a subscription (callable by anyone)
     * @param subscriptionId ID of the subscription to process
     */
    function processPayment(uint256 subscriptionId) external {
        Subscription storage sub = subscriptions[subscriptionId];
        
        require(sub.active, "Subscription inactive");
        require(sub.subscriber != address(0), "Invalid subscription");
        
        uint32 currentTime = uint32(block.timestamp);
        uint32 nextPaymentTime = sub.lastPaymentTime + sub.interval;
        
        require(currentTime >= nextPaymentTime, "Payment not due");

        // Update storage only once
        sub.lastPaymentTime = currentTime;

        // Direct transfer to avoid extra storage operations
        (bool success, ) = owner.call{value: sub.amount}("");
        require(success, "Transfer failed");

        emit PaymentProcessed(subscriptionId, sub.subscriber, sub.amount, currentTime);
    }

    /**
     * @dev Batch process multiple subscriptions to save gas
     * @param subscriptionIds Array of subscription IDs to process
     */
    function batchProcessPayments(uint256[] calldata subscriptionIds) external {
        uint32 currentTime = uint32(block.timestamp);
        uint256 totalAmount;

        for (uint256 i = 0; i < subscriptionIds.length; i++) {
            uint256 subscriptionId = subscriptionIds[i];
            Subscription storage sub = subscriptions[subscriptionId];
            
            if (!sub.active || sub.subscriber == address(0)) continue;
            
            uint32 nextPaymentTime = sub.lastPaymentTime + sub.interval;
            if (currentTime < nextPaymentTime) continue;

            sub.lastPaymentTime = currentTime;
            totalAmount += sub.amount;

            emit PaymentProcessed(subscriptionId, sub.subscriber, sub.amount, currentTime);
        }

        if (totalAmount > 0) {
            (bool success, ) = owner.call{value: totalAmount}("");
            require(success, "Transfer failed");
        }
    }

    /**
     * @dev Cancel a subscription (only subscriber)
     * @param subscriptionId ID of the subscription to cancel
     */
    function cancelSubscription(uint256 subscriptionId) external onlySubscriber(subscriptionId) {
        subscriptions[subscriptionId].active = false;
        emit SubscriptionCancelled(subscriptionId);
    }

    /**
     * @dev Get user's active subscription IDs
     * @param user Address to query
     */
    function getUserSubscriptions(address user) external view returns (uint256[] memory) {
        return userSubscriptions[user];
    }

    /**
     * @dev Check if payment is due for a subscription
     * @param subscriptionId ID of the subscription to check
     */
    function isPaymentDue(uint256 subscriptionId) external view returns (bool) {
        Subscription storage sub = subscriptions[subscriptionId];
        return sub.active && 
               block.timestamp >= sub.lastPaymentTime + sub.interval;
    }

    /**
     * @dev Get next payment time for a subscription
     * @param subscriptionId ID of the subscription
     */
    function getNextPaymentTime(uint256 subscriptionId) external view returns (uint256) {
        Subscription storage sub = subscriptions[subscriptionId];
        return sub.active ? sub.lastPaymentTime + sub.interval : 0;
    }

    /**
     * @dev Withdraw accumulated funds (owner only)
     */
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds");
        (bool success, ) = owner.call{value: balance}("");
        require(success, "Transfer failed");
    }

    // Receive function to handle accidental ETH sends
    receive() external payable {}
}