// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Lottery {
    address public owner;
    address[] private participants;
    uint256 public lotteryPot;

    constructor() {
        owner = msg.sender;
    }

    function joinLottery() public payable {
        require(msg.value > 0.01 ether, "Minimum 0.01 Ether to join");

        participants.push(msg.sender);
        lotteryPot += msg.value;
    }

    function getRandomNumber() private view returns (uint256) {
        return uint256(
            keccak256(
                abi.encodePacked(block.timestamp, block.difficulty, participants.length)
            )
        );
    }

    function selectWinner() public onlyOwner {
        require(participants.length > 0, "No participants");

        uint256 randomIndex = getRandomNumber() % participants.length;
        address winner = participants[randomIndex];

        uint256 prize = lotteryPot;
        lotteryPot = 0;
        delete participants;

        (bool success, ) = winner.call{value: prize}("");
        require(success, "Transfer failed");
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }
}

