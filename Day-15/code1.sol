// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

contract A{
    function func1() public pure returns(string memory){
        return "Contract 1 A";
    }

    function func2() public pure virtual returns(string memory){
        return "Contract 1 B";
    }

    function func3() public pure virtual returns(string memory){
        return "Contract 1 C";
    }
}

contract B is A{
    function func2() public pure override returns(string memory){
        return "Contract 2 B";
    }

    function func3() public pure override virtual returns(string memory){
        return "Contract 2 C";
    }
}

contract C is B{
    function func3() public pure override returns(string memory){
        return "Contract 3 C";
    }
}

