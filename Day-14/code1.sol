// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

contract A{
    function func1() public pure returns(string memory){
        return "I'm in A";
    }

    function func2() public pure virtual returns(string memory){
        return "I'm in A";
    }

    function func3() public pure virtual returns(string memory){
        return "I'm in A";
    }
}

contract B is A{
    function func2() public pure override returns(string memory){
        return "I'm in B";
    }
}

contract C is A{
    function func3() public pure override  returns(string memory){
        return "I'm in C";
    }
}