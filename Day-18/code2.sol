// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleStorage{
    uint private storedData;

    function set(uint x) external {
        storedData = x;
    }

    function get() external view returns(uint){
        return storedData;
    }
}