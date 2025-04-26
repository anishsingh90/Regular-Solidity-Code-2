// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

contract SolidityTest{
    uint nums1;
    uint nums2;
    uint sum = nums1 + nums2;

    constructor() public {
        nums1 = 10;
        nums2 = 20;
        sum = nums1 + nums2;
    }

    function Sum() public view returns(uint){
        return sum;
    }
}
