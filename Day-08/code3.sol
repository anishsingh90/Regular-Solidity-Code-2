// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

contract SolidityString{ 
    string userInput;

    function set(string memory finalValue) public {
        userInput = finalValue;
    }

    function get() public view returns(string memory ){
        return userInput;
    }
}
