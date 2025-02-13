// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

contract SolidityTest{
    function factorial(uint n) public pure returns(uint){
        if(n == 0 || n == 1){
            return 1;
        }
        return n * factorial(n-1); 
    }
}
