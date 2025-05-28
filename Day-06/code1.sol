// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

contract SolidityLearn{
    string text;

    function setText() public returns(string memory){
        text = "Anish";
    } 
 
    function getText() public view returns(string memory){
        return text;
    }
}
