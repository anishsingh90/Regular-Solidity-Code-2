// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract InputValidation {
    uint public storedNumber;
    string public storedString;

    // Store a number, only if it's positive and less than 1000.
    function storeNumber(uint _number) public {
        require(_number > 0, "Number must be positive");
        require(_number < 1000, "Number must be less than 1000");
        storedNumber = _number; // Renamed variable
    }

    // Store a string, only if it's not empty and less than 20 characters.
    function storeString(string memory _str) public {
        require(bytes(_str).length > 0, "String must not be empty");
        require(bytes(_str).length < 20, "String must be less than 20 characters");
        storedString = _str; // Renamed variable
    }

    // Example: Validate that an address is not zero.
    function validateAddress(address _addr) public pure returns(bool){
        return (_addr != address(0));
    }
}

