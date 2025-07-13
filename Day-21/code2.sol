// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RealEstateOwnershipTracker {
    // Struct to store property information
    struct Property {
        uint256 id;
        string physicalAddress;
        string legalDescription;
        uint256 area; // in square meters
        uint256 purchasePrice;
        uint256 purchaseDate;
        address currentOwner;
        bool exists;
    }

    // Struct to store ownership transfer history
    struct OwnershipTransfer {
        uint256 propertyId;
        address previousOwner;
        address newOwner;
        uint256 transferDate;
        string transferReason;
    }

    // Mapping from property ID to Property
    mapping(uint256 => Property) public properties;
    
    // Mapping from property ID to array of OwnershipTransfer
    mapping(uint256 => OwnershipTransfer[]) public ownershipHistory;
    
    // Counter for property IDs
    uint256 public nextPropertyId = 1;
    
    // Events
    event PropertyRegistered(
        uint256 indexed propertyId,
        address indexed owner,
        string physicalAddress
    );
    
    event OwnershipTransferred(
        uint256 indexed propertyId,
        address indexed previousOwner,
        address indexed newOwner,
        uint256 transferDate
    );

    // Modifier to check if property exists
    modifier propertyExists(uint256 _propertyId) {
        require(properties[_propertyId].exists, "Property does not exist");
        _;
    }

    // Modifier to check if sender is the current owner
    modifier onlyOwner(uint256 _propertyId) {
        require(
            msg.sender == properties[_propertyId].currentOwner,
            "Only the current owner can perform this action"
        );
        _;
    }

    /**
     * @dev Register a new property
     * @param _physicalAddress The physical address of the property
     * @param _legalDescription Legal description of the property
     * @param _area Area in square meters
     * @param _purchasePrice Purchase price in wei
     */
    function registerProperty(
        string memory _physicalAddress,
        string memory _legalDescription,
        uint256 _area,
        uint256 _purchasePrice
    ) external returns (uint256) {
        uint256 propertyId = nextPropertyId++;
        
        properties[propertyId] = Property({
            id: propertyId,
            physicalAddress: _physicalAddress,
            legalDescription: _legalDescription,
            area: _area,
            purchasePrice: _purchasePrice,
            purchaseDate: block.timestamp,
            currentOwner: msg.sender,
            exists: true
        });
        
        // Record initial ownership
        ownershipHistory[propertyId].push(OwnershipTransfer({
            propertyId: propertyId,
            previousOwner: address(0),
            newOwner: msg.sender,
            transferDate: block.timestamp,
            transferReason: "Initial registration"
        }));
        
        emit PropertyRegistered(propertyId, msg.sender, _physicalAddress);
        
        return propertyId;
    }

    /**
     * @dev Transfer ownership of a property
     * @param _propertyId ID of the property
     * @param _newOwner Address of the new owner
     * @param _transferReason Reason for the transfer (sale, gift, inheritance, etc.)
     */
    function transferOwnership(
        uint256 _propertyId,
        address _newOwner,
        string memory _transferReason
    ) external propertyExists(_propertyId) onlyOwner(_propertyId) {
        require(_newOwner != address(0), "New owner cannot be the zero address");
        require(_newOwner != properties[_propertyId].currentOwner, "New owner cannot be the current owner");

        address previousOwner = properties[_propertyId].currentOwner;
        properties[_propertyId].currentOwner = _newOwner;
        
        // Record the transfer
        ownershipHistory[_propertyId].push(OwnershipTransfer({
            propertyId: _propertyId,
            previousOwner: previousOwner,
            newOwner: _newOwner,
            transferDate: block.timestamp,
            transferReason: _transferReason
        }));
        
        emit OwnershipTransferred(_propertyId, previousOwner, _newOwner, block.timestamp);
    }

    /**
     * @dev Get property details
     * @param _propertyId ID of the property
     */
    function getPropertyDetails(uint256 _propertyId)
        external
        view
        propertyExists(_propertyId)
        returns (
            string memory,
            string memory,
            uint256,
            uint256,
            uint256,
            address
        )
    {
        Property memory property = properties[_propertyId];
        return (
            property.physicalAddress,
            property.legalDescription,
            property.area,
            property.purchasePrice,
            property.purchaseDate,
            property.currentOwner
        );
    }

    /**
     * @dev Get ownership history of a property
     * @param _propertyId ID of the property
     */
    function getOwnershipHistory(uint256 _propertyId)
        external
        view
        propertyExists(_propertyId)
        returns (OwnershipTransfer[] memory)
    {
        return ownershipHistory[_propertyId];
    }

    /**
     * @dev Verify ownership of a property
     * @param _propertyId ID of the property
     * @param _owner Address to verify
     */
    function verifyOwnership(uint256 _propertyId, address _owner)
        external
        view
        propertyExists(_propertyId)
        returns (bool)
    {
        return properties[_propertyId].currentOwner == _owner;
    }
}