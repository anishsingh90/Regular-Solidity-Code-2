// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AuctionSystem{
    address payable public auctioneer;
    uint public auctionEndTime;
    uint public highestBid;
    uint public highestBidder;
    bool public auctionEnded;

    mapping (uint => address) public pendingReturns;

    event AuctionStarted(uint endTime);

}