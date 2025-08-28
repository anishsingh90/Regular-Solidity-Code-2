// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract avgCalulator{
    struct AverageData{
        uint128 totalSum;
        uint32 count;
        uint96 lastAverage;
    }

    AverageData private averageData;

    event NumberAdded(uint256 number, uint256 newAverage);
    event AverageReset();

    function addNumber(uint256 _number) external {
        AverageData memory data = averageData;

        uint256 newTotalSum = data.totalSum + _number;
        uint32 newCount = data.count + 1;

        uint256 preciseAverage = (newTotalSum * 1000) / newCount;

        averageData = AverageData({
            totalSum: uint128(newTotalSum),
            count: newCount,
            lastAverage: uint96(preciseAverage)
        });

        emit NumberAdded(_number, preciseAverage);
    }

    function getAverage() external view returns(uint256){
        return averageData.lastAverage;
    }

    function getReadableAverage() external view returns(uint256){
        return averageData.lastAverage / 1000;
    }

    function reset() external {
        averageData = AverageData(0, 0, 0);
        emit AverageReset();
    }

    function getStats() external view returns (uint256 totalSum, uint256 count, uint256 preciseAverage){
        AverageData memory data = averageData;
        return (data.totalSum, data.count, data.lastAverage);
    }
}