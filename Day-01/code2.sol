// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

contract SolidityTest{
    uint storedNumber;

    function set(uint newNumber) public {
        storedNumber = newNumber;
    }

    function get() public view returns(uint){
        return storedNumber;
    }
}
