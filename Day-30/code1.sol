// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Auction{
    address public seller;
    uint public endTime;
    address public highestBidder;
    uint public highestBid;
    bool public ended;

    mapping(address => uint) public pendingReturns;

    event HighestBidIncreased(address bidder, uint amount);
    event AcutionEnded(address winner, uint amount);

    constructor(uint _biddingTime){
        seller = msg.sender;
        endTime = block.timestamp + _biddingTime;
    }

    function bid() external payable{
        require(block.timestamp < endTime, "Auction already ended.");
        require(msg.value > highestBid, "There already is a higher bid.");

        if(highestBid != 0){
            pendingReturns[highestBidder] += highestBid;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;
        emit HighestBidIncreased(msg.sender, msg.value);
    }

    function withdraw() external returns(bool){
        uint amount = pendingReturns[msg.sender];
        require(amount > 0, "No funds to withdraw.");

        pendingReturns[msg.sender] = 0;

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        if(!success){
            pendingReturns[msg.sender] = amount;
            return false;
        }
        return true;
    }

    function endAuction() external {
        require(block.timestamp >= endTime, "Auction not yet ended.");
        require(!ended, "endAuction has already been called.");
        require(msg.sender == seller, "Only seller can end auction.");

        ended = true;
        emit AcutionEnded(highestBidder, highestBid);

        (bool success, ) = payable(seller).call{value: highestBid}("");
        require(success, "Transfer to seller failed.");
    }
}