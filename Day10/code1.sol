// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

contract ModifierWithoutArg{
    address admin;
    struct employee{
        uint emp_id;
        string emp_name;
        uint age;
    }

    constructor() public {
        admin = msg.sender;
    }

    modifier isAdmin{
        require(admin == msg.sender);
        _;
    }

    employee e;
     function enterDetails(uint _empid, string memory _empname, uint _empage) public isAdmin{
        e.emp_id = _empid;
        e.emp_name = _empname;
        e.age = _empage;
     }
}
