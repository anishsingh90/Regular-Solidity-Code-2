// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Simple Auction Contract
/// @author Copilot
/// @notice This contract implements a simple auction where bidders can place bids and the highest bidder wins.
contract Auction {
    address public owner;
    address public highestBidder;
    uint public highestBid;
    uint public auctionEndTime;
    bool public ended;

    mapping(address => uint) public pendingReturns;

    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    /// @dev Modifier to restrict functions to the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }

    /// @notice Initialize the auction with a bidding duration in seconds
    /// @param _biddingTime Duration of the auction in seconds
    constructor(uint _biddingTime) {
        owner = msg.sender;
        auctionEndTime = block.timestamp + _biddingTime;
    }

    /// @notice Place a bid on the auction
    function bid() external payable {
        require(block.timestamp < auctionEndTime, "Auction already ended.");
        require(msg.value > highestBid, "There already is a higher bid.");

        if (highestBid != 0) {
            // Refund the previous highest bidder
            pendingReturns[highestBidder] += highestBid;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;
        emit HighestBidIncreased(msg.sender, msg.value);
    }

    /// @notice Withdraw your pending returns if you were outbid
    function withdraw() external returns (bool) {
        uint amount = pendingReturns[msg.sender];
        if (amount > 0) {
            pendingReturns[msg.sender] = 0;
            if (!payable(msg.sender).send(amount)) {
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    /// @notice End the auction and send funds to the owner
    function endAuction() external onlyOwner {
        require(block.timestamp >= auctionEndTime, "Auction not yet ended.");
        require(!ended, "endAuction has already been called.");

        ended = true;
        emit AuctionEnded(highestBidder, highestBid);

        payable(owner).transfer(highestBid);
    }
}