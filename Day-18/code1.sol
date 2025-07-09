// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleStorage{
    string private StoredValue;

    function set(string calldata value) external {
        StoredValue = value;
    }

    function get() external view returns(string memory){
        return StoredValue;
    }
}