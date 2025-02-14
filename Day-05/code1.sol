// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

contract Solidity{
    string text;

    function setText() public returns(string memory){
        text = "Anish Singh";
    }
    
    function getText() public view returns(string memory){
        return text;
    }
}