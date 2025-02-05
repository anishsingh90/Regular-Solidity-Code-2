// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

contract SimpleCounter{
    uint counter;

    function increamentCounter() public {
        counter = counter + 1;
    }

    function getCounter() public view returns(uint){
        return counter;
    }
}