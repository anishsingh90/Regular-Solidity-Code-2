// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

contract LearningString{
    function getLength(string memory s) public pure returns(uint256){
        bytes memory b = bytes(s);
        return b.length;
    }
}