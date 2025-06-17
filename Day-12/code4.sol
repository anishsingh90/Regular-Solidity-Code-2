// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract mapping_example{
    struct student{
        string name;
        string subject;
        uint8 marks;
    }

    mapping (address => student) result;
    address[] public student_result;
}