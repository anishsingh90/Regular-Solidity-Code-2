// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

contract A{
    function func1() public pure returns(string memory){
        return "Anish Singh";
    }

    function func2() public pure virtual returns(string memory){
        return "I pursuing B.Tech(CSE)";
    }
}

contract B is A{
    function func2() public pure override returns(string memory){
        return "I pursuing B.Tech(IT)";
    }
}