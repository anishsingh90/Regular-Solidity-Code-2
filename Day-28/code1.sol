// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Lottery {
    address public manager;
    address[] public players; // all players are stored in array
    address public winner;

    event PlayerJoined(address indexed player);
    event WinnerSelected(address indexed winner);

    // Define the onlyManager modifier
    modifier onlyManager() {
        require(msg.sender == manager, "Only the manager can call this function");
        _;
    }

    constructor() {
        manager = msg.sender;
    }

    // Function for users to join the lottery
    function join() public payable {
        require(msg.value == 0.01 ether, "Entry fee is 0.01 ETH");
        players.push(msg.sender);
        emit PlayerJoined(msg.sender);
    }

    // Only manager can pick winner
    function pickWinner() public onlyManager {
        require(players.length > 0, "No players in the lottery");
        uint index = random() % players.length;
        winner = players[index];

        // Transfer all contract balance to the winner
        payable(winner).transfer(address(this).balance);
        emit WinnerSelected(winner);

        // Reset for next round
        delete players;
    }

    // Generates a pseudo-random number (NOT secure for production)
    function random() private view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
    }

    // Get all players
    function getPlayers() public view returns (address[] memory) {
        return players;
    }
}