// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

contract EvenOrOdd{
    uint num;

    function setNum(uint _Num) public {
        num = _Num;
    }

    function Check() public view returns(string memory){
        if(num%2==0){
            return "Even Number";
        }
        else{
            return "Odd Number";
        }
    }
}