// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

contract LearningStrings{
    string public text;

    function setText() public {
        text = 'hello';
    }

    function setTextByPassing(string memory message) public {
        text = message;
    }

    function getText() view public returns(string memory){
        return text;
    }
}