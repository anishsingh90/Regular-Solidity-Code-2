// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract EmployeeSalaryTracker {
    struct Employee {
        uint256 salary; // Salary in wei (or any smallest denomination)
        uint256 lastPaymentDate; // Timestamp of last payment
        bool exists;
    }

    address public owner;
    mapping(address => Employee) public employees;

    event EmployeeAdded(address indexed employee, uint256 salary);
    event SalaryUpdated(address indexed employee, uint256 newSalary);
    event SalaryPaid(address indexed employee, uint256 amount, uint256 date);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    modifier onlyEmployee() {
        require(employees[msg.sender].exists, "Not an employee");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addEmployee(address _employee, uint256 _salary) external onlyOwner {
        require(!employees[_employee].exists, "Employee already exists");
        require(_salary > 0, "Salary must be positive");
        employees[_employee] = Employee({
            salary: _salary,
            lastPaymentDate: 0,
            exists: true
        });
        emit EmployeeAdded(_employee, _salary);
    }

    function updateSalary(address _employee, uint256 _newSalary) external onlyOwner {
        require(employees[_employee].exists, "Employee does not exist");
        require(_newSalary > 0, "Salary must be positive");
        employees[_employee].salary = _newSalary;
        emit SalaryUpdated(_employee, _newSalary);
    }

    // Owner pays salary to specific employee, records payment date
    function paySalary(address _employee) external payable onlyOwner {
        Employee storage emp = employees[_employee];
        require(emp.exists, "Employee does not exist");
        require(msg.value == emp.salary, "Incorrect salary amount");

        emp.lastPaymentDate = block.timestamp;
        payable(_employee).transfer(msg.value);

        emit SalaryPaid(_employee, msg.value, block.timestamp);
    }

    // Get employee's last payment date and salary
    function getEmployeeInfo(address _employee) external view returns (uint256 salary, uint256 lastPaymentDate) {
        Employee storage emp = employees[_employee];
        require(emp.exists, "Employee does not exist");
        return (emp.salary, emp.lastPaymentDate);
    }

    // Allow contract to receive Ether
    receive() external payable {}
}