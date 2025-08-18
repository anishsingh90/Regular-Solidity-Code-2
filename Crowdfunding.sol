// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract CrowdFunding {
    struct Campaign {
        address owner;
        string title;
        string description;
        uint256 target;
        uint256 deadline;
        uint256 amountCollected;
        string image;
        bool paid;
    }

    mapping(uint256 => Campaign) public campaigns;
    mapping(uint256 => address[]) public campaignDonators;
    mapping(uint256 => uint256[]) public campaignDonations;

    uint256 public numberOfCampaigns = 0;

    function createCampaign(
        string memory _title,
        string memory _description,
        uint256 _target,
        uint256 _deadline,
        string memory _image
    ) public returns (uint256) {
        require(_target > 0, "Target must be greater than 0");
        require(_deadline > block.timestamp, "Deadline must be in the future");

        Campaign storage newCampaign = campaigns[numberOfCampaigns];
        newCampaign.owner = msg.sender;
        newCampaign.title = _title;
        newCampaign.description = _description;
        newCampaign.target = _target;
        newCampaign.deadline = _deadline;
        newCampaign.image = _image;
        newCampaign.paid = false;

        numberOfCampaigns++;

        return numberOfCampaigns - 1;
    }

    function donateToCampaign(uint256 _id) public payable {
        uint256 amount = msg.value;
        Campaign storage campaign = campaigns[_id];

        require(block.timestamp < campaign.deadline, "Campaign has ended");
        require(amount > 0, "Donation must be greater than 0");

        campaign.amountCollected = campaign.amountCollected + amount;
        campaignDonators[_id].push(msg.sender);
        campaignDonations[_id].push(amount);
    }

    function getDonators(uint256 _id)
        public
        view
        returns (address[] memory, uint256[] memory)
    {
        return (campaignDonators[_id], campaignDonations[_id]);
    }

    function getCampaigns() public view returns (Campaign[] memory) {
        Campaign[] memory allCampaigns = new Campaign[](numberOfCampaigns);

        for (uint256 i = 0; i < numberOfCampaigns; i++) {
            Campaign storage item = campaigns[i];
            allCampaigns[i] = item;
        }

        return allCampaigns;
    }

    function claimRefund(uint256 _id) public {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp > campaign.deadline, "Campaign has not ended yet");
        require(
            campaign.amountCollected < campaign.target,
            "Campaign was successful, no refunds"
        );

        address[] storage donators = campaignDonators[_id];
        uint256[] storage donations = campaignDonations[_id];
        uint256 totalDonatedByUser = 0;
        
        for (uint256 i = 0; i < donators.length; i++) {
            if (donators[i] == msg.sender) {
                totalDonatedByUser += donations[i];
                donations[i] = 0; // Prevent re-entrancy and double claims
            }
        }

        require(totalDonatedByUser > 0, "You did not donate to this campaign");

        (bool sent, ) = msg.sender.call{value: totalDonatedByUser}("");
        require(sent, "Failed to send Ether");
    }

    function payoutCampaign(uint256 _id) public {
        Campaign storage campaign = campaigns[_id];
        require(
            campaign.owner == msg.sender,
            "You are not the owner of this campaign"
        );
        require(
            campaign.amountCollected >= campaign.target,
            "Campaign did not reach its target"
        );
        require(!campaign.paid, "Campaign has already been paid out");

        campaign.paid = true;
        (bool sent, ) = msg.sender.call{value: campaign.amountCollected}("");
        require(sent, "Failed to send Ether");
    }
}
