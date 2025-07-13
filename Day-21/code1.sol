// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VotingSystem{
    address public owner;

    struct Candidate{
        uint id;
        string name;
        uint voteCount;
    }

    mapping (uint => Candidate) public candidate;
    uint public candidatesCount;

    mapping (address => bool) public voters;
    mapping (address => bool) public hasVoted;

    uint public votingStart;
    uint public votingEnd;
    bool public electionStarted;

    modifier onlyOwner(){
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    modifier duringVotingPeriod(){
        require(electionStarted, "Election not started");
        require(block.timestamp >= votingStart && block.timestamp <= votingEnd, "Not within voting period");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function startElection(uint _durationInMinutes) public onlyOwner{
        require(!electionStarted, "Already started");
        votingStart = block.timestamp;
        votingEnd = votingStart + (_durationInMinutes * 1 minutes);
        electionStarted = true;
    }

    function addCandidate(string memory _name) public onlyOwner{
        require(!electionStarted, "Cannot add candidates after election starts");
        candidatesCount++;
        candidate[candidatesCount] = Candidate(candidatesCount, _name, 0);
    }

    function vote(uint _candidateId) public duringVotingPeriod{
        require(voters[msg.sender], "Not a registred voter");
        require(!hasVoted[msg.sender], "Already voted");
        require(_candidateId > 0 && _candidateId <= candidatesCount, "Invalid candidate ID");

        candidate[_candidateId].voteCount++;
        hasVoted[msg.sender] = true;
    }

    function getResults() public view returns(Candidate[] memory){
        require(block.timestamp > votingEnd, "Voting not ended yet");

        Candidate[] memory results = new Candidate[](candidatesCount);
        for(uint i = 1; i <= candidatesCount; i++){
            results[i - 1] = candidate[i];
        }
        return results;
    }

    function getTimeRemaining() public view returns(uint){
        if (block.timestamp >= votingEnd) return 0;
        return votingEnd - block.timestamp;
    }
}