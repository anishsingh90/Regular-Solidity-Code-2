// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BlockLatencyReason {
    struct BlockInfo {
        string reason;
        uint256 latency; // store latency once generated
        bool generated;  // to check if latency already generated
    }

    // Mapping for block → info
    mapping(uint256 => BlockInfo) public blockData;

    constructor() {
        // Pre-load reasons (latency will be generated on demand)
        blockData[1].reason = "Farmer KYC submission Initial transaction setup";
        blockData[2].reason = "Govt. Fund Allocation Subsidy approval and fund allocation";
        blockData[3].reason = "Seed wholesaler order Seed supply request confirmed";
        blockData[4].reason = "Seed delivery to farmer Digital order confirmation";
        blockData[5].reason = "Payment release to wholesaler Delivery tracking validation";
        blockData[6].reason = "Crop Growth and harvest Crop sowing recorded";
        blockData[7].reason = "Received harvest crop from farmer Field monitoring entry";
        blockData[8].reason = "Send corn to processing unit IoT data monitoring";
        blockData[9].reason = "Retail distribution Transport & validation";
        blockData[10].reason = "Consumer Purchase Computation and quality check";
        blockData[11].reason = "Retail distribution Consumer level checkpoint";
        blockData[12].reason = "Wholesaler to consumer Demand aggregation";
        blockData[13].reason = "Consumer purchase Multiple buyers transactions";
        blockData[14].reason = "Payment settlement Simple settlement confirmation";
        blockData[15].reason = "Repeat transaction Optimized repeat pattern";
        blockData[16].reason = "Confirmation Final consumer confirmation record";
    }

    // Generate or fetch fixed latency for block
    function getLatency(uint256 blockNumber) public returns (string memory reason, uint256 latency) {
        require(bytes(blockData[blockNumber].reason).length > 0, "Block not found");

        // If already generated, return same latency
        if (blockData[blockNumber].generated) {
            return (blockData[blockNumber].reason, blockData[blockNumber].latency);
        }

        
        uint256 random = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, msg.sender, blockNumber)));
        uint256 latencyValue = (random % 551) + 250;

        blockData[blockNumber].latency = latencyValue;
        blockData[blockNumber].generated = true;

        return (blockData[blockNumber].reason, latencyValue);
    }
}
