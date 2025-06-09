// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

contract Test{
    function Calculate() public pure returns(uint product, uint sum){
        uint num1 = 10;
        uint num2 = 5;

        product = num1 * num2;

        sum = num1 + num2;
    }
}