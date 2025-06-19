// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

contract ConstructorCall{
    string str;

    constructor() public {
        str = "Hello World!";
    }

    function getValue() public view returns(string memory){
        return str;
    }
}