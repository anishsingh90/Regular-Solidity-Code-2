// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/Strings.sol";

contract ProjectRegistry {
    struct Project {
        string title;
        string description;
        string[] technologies;
        string githubLink;
        string liveDemoLink;
        string image;
        string dataAiHint;
    }

    Project[] public projects;
    mapping(address => bool) public admins;
    address public contractOwner;

    event ProjectAdded(uint256 projectId, string title);
    event ProjectUpdated(uint256 projectId, string title);
    event ProjectDeleted(uint256 projectId);

    constructor() {
        contractOwner = msg.sender;
        admins[msg.sender] = true;
    }

    modifier onlyAdmin() {
        require(admins[msg.sender], "Only admins can perform this action");
        _;
    }

    function addProject(
        string memory _title,
        string memory _description,
        string[] memory _technologies,
        string memory _githubLink,
        string memory _liveDemoLink,
        string memory _image,
        string memory _dataAiHint
    ) public onlyAdmin {
        projects.push(Project({
            title: _title,
            description: _description,
            technologies: _technologies,
            githubLink: _githubLink,
            liveDemoLink: _liveDemoLink,
            image: _image,
            dataAiHint: _dataAiHint
        }));
        emit ProjectAdded(projects.length - 1, _title);
    }

    function updateProject(
        uint256 _projectId,
        string memory _title,
        string memory _description,
        string[] memory _technologies,
        string memory _githubLink,
        string memory _liveDemoLink,
        string memory _image,
        string memory _dataAiHint
    ) public onlyAdmin {
        require(_projectId < projects.length, "Project does not exist");
        Project storage projectToUpdate = projects[_projectId];
        projectToUpdate.title = _title;
        projectToUpdate.description = _description;
        projectToUpdate.technologies = _technologies;
        projectToUpdate.githubLink = _githubLink;
        projectToUpdate.liveDemoLink = _liveDemoLink;
        projectToUpdate.image = _image;
        projectToUpdate.dataAiHint = _dataAiHint;
        emit ProjectUpdated(_projectId, _title);
    }

    function deleteProject(uint256 _projectId) public onlyAdmin {
        require(_projectId < projects.length, "Project does not exist");
        // This is not gas-efficient for large arrays, but suitable for a portfolio
        for (uint i = _projectId; i < projects.length - 1; i++) {
            projects[i] = projects[i + 1];
        }
        projects.pop();
        emit ProjectDeleted(_projectId);
    }

    function getProjects() public view returns (Project[] memory) {
        return projects;
    }

    function getProjectCount() public view returns (uint) {
        return projects.length;
    }
}
