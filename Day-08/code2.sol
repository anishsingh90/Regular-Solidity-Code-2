// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

contract Solidity{
    uint a;

    function set(uint x) public {
        a = x;
    }

    function get() public view returns(uint){
        return a;
    }
}