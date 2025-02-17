// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

contract SolidityTest{
    string text;

    function setText() public {
        text = "Hello";
    }

    function setTextByPassing(string memory message) public {
        text = message;
    }

    function getText() public view returns(string memory){
        return text;
    }
}
