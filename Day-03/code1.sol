// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

contract Type{

    enum week_days{
        Monday,
        Tuesday,
        Wednesday,
        Thursday,
        Friday,
        Saturday,
        Sunday
    }

    week_days week;
    week_days choice; 

    week_days constant default_value = week_days.Sunday;

    function set_Value() public {
        choice = week_days.Thursday;
    }

    function get_Choice() public view returns(week_days){
        return choice;
    }

    function getdefaultvalue() public pure returns(week_days){
        return default_value;
    }
}