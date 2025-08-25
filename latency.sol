// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BlockLatencyReason {
    struct BlockInfo {
        string reason;
    }

  
    mapping(uint256 => BlockInfo) public blockReasons;

    constructor() {
        
        blockReasons[1] = BlockInfo("Farmer KYC submission  Initial transaction setup");
        blockReasons[2] = BlockInfo("Govt. Fund Allocation  Subsidy approval and fund allocation");
        blockReasons[3] = BlockInfo("Seed wholesaler order Seed supply request confirmed");
        blockReasons[4] = BlockInfo("Seed delivery to farmer Digital order confirmation");
        blockReasons[5] = BlockInfo("Payment release to wholesaler Delivery tracking validation");
        blockReasons[6] = BlockInfo("Crop Growth and harvest Crop sowing recorded");
        blockReasons[7] = BlockInfo("Received harvest crop from farmer Field monitoring entry");
        blockReasons[8] = BlockInfo("Send corn to processing unit IoT data monitoring");
        blockReasons[9] = BlockInfo("Retail distribution Transport & validation");
        blockReasons[10] = BlockInfo("Consumer Purchase Computation and quality check");
        blockReasons[11] = BlockInfo("Retail distribution Consumer level checkpoint");
        blockReasons[12] = BlockInfo("Wholesaler to consumer Demand aggregation");
        blockReasons[13] = BlockInfo("Consumer purchase Multiple buyers transactions");
        blockReasons[14] = BlockInfo("Payment settlement Simple settlement confirmation");
        blockReasons[15] = BlockInfo("Repeat transaction Optimized repeat pattern");
        blockReasons[16] = BlockInfo("Confirmation Final consumer confirmation record");
    }

   
    function getLatency(uint256 blockNumber) public view returns (string memory reason, uint256 latency) {
        require(bytes(blockReasons[blockNumber].reason).length > 0, "Block not found");

        
        uint256 random = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, msg.sender, blockNumber)));

        
        uint256 latencyValue = (random % 551) + 250;

        return (blockReasons[blockNumber].reason, latencyValue);
    }
}
