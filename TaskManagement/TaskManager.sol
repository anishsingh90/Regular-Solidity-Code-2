// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract TaskManager{
    struct Task {
        uint256 id;
        string title;
        string description;
        bool completed;
        address owner;
    }

    mapping(uint256 => Task) public tasks;
    uint256 public nextTaskId;

    event TaskCreated(uint256 indexed taskId, string title, address owner);
    event TaskUpdated(uint256 indexed taskId, string title, bool completed);
    event TaskDeleted(uint256 indexed taskId);

    modifier onlyTaskOwner(uint256 _taskId) {
        require(tasks[_taskId].owner == msg.sender, "Not task owner");
        _;
    }

    function addTask(string memory _title, string memory _description) public {
        tasks[nextTaskId] = Task(nextTaskId, _title, _description, false, msg.sender);
        emit TaskCreated(nextTaskId, _title, msg.sender);
        nextTaskId++;
    }

    function editTask(uint256 _taskId, string memory _newTitle, string memory _newDescription) public onlyTaskOwner(_taskId) {
        Task storage task = tasks[_taskId];
        task.title = _newTitle;
        task.description = _newDescription;
        emit TaskUpdated(_taskId, _newTitle, task.completed);
    }

    function markTaskCompleted(uint256 _taskId) public onlyTaskOwner(_taskId) {
        Task storage task = tasks[_taskId];
        task.completed = true;
        emit TaskUpdated(_taskId, task.title, true);
    }

    function deleteTask(uint256 _taskId) public onlyTaskOwner(_taskId) {
        delete tasks[_taskId];
        emit TaskDeleted(_taskId);
    }

    function getTask(uint256 _taskId) public view returns (Task memory) {
        return tasks[_taskId];
    }
}
