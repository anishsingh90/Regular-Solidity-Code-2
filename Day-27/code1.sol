// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Marketplace {
    struct Item {
        uint256 id;
        address payable owner;
        string name;
        string description;
        uint256 price;
        bool forSale;
    } 

    uint256 public itemCount = 0;
    mapping(uint256 => Item) public items;

    event ItemRegistered(uint256 indexed itemId, address indexed owner, string name, uint256 price);
    event ItemListed(uint256 indexed itemId, uint256 price);
    event ItemDelisted(uint256 indexed itemId);
    event ItemSold(uint256 indexed itemId, address indexed from, address indexed to, uint256 price);

    modifier onlyOwner(uint256 _itemId) {
        require(items[_itemId].owner == msg.sender, "Not the item owner");
        _;
    }

    // Register a new item
    function registerItem(string memory _name, string memory _description, uint256 _price) external {
        require(_price > 0, "Price must be greater than zero");
        itemCount++;
        items[itemCount] = Item(itemCount, payable(msg.sender), _name, _description, _price, false);
        emit ItemRegistered(itemCount, msg.sender, _name, _price);
    }

    // List item for sale
    function listItem(uint256 _itemId, uint256 _price) external onlyOwner(_itemId) {
        Item storage item = items[_itemId];
        require(!item.forSale, "Already listed");
        require(_price > 0, "Price must be greater than zero");
        item.price = _price;
        item.forSale = true;
        emit ItemListed(_itemId, _price);
    }

    // Delist item from sale
    function delistItem(uint256 _itemId) external onlyOwner(_itemId) {
        Item storage item = items[_itemId];
        require(item.forSale, "Not listed");
        item.forSale = false;
        emit ItemDelisted(_itemId);
    }

    // Buy an item
    function buyItem(uint256 _itemId) external payable {
        Item storage item = items[_itemId];
        require(item.forSale, "Item not for sale");
        require(msg.value == item.price, "Incorrect value sent");
        require(item.owner != msg.sender, "Cannot buy your own item");

        address payable previousOwner = item.owner;
        item.owner = payable(msg.sender);
        item.forSale = false;

        previousOwner.transfer(msg.value);

        emit ItemSold(_itemId, previousOwner, msg.sender, msg.value);
    }

    // View item details
    function getItem(uint256 _itemId) external view returns (
        uint256 id,
        address owner,
        string memory name,
        string memory description,
        uint256 price,
        bool forSale
    ) {
        Item memory item = items[_itemId];
        return (item.id, item.owner, item.name, item.description, item.price, item.forSale);
    }
}