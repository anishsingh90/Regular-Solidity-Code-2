// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract userManager{
    //Array to store user addresses
    address[] private users;

    //Events to log actions
    event UserAdded(address indexed user);
    event UserRemoved(address indexed user);

    //Function to add user
    function addUser(address _user) external{
        require(_user != address(0), "Invalid Address");
        require(!isUser(_user), "User already exists");

        users.push(_user);
        emit UserAdded(_user);
    }

    //Function to remove a user
    function removeUser(address _user) external {
        require(_user != address(0), "Invalid address");
        require(isUser(_user), "User does not exist");

        for(uint i = 0; i < users.length; i++){
            if(users[i] == _user){
                //Move last element to current position
                users[i] = users[users.length - 1];
                //Remove last element
                users.pop();
                emit UserRemoved(_user);
                return;
            }
        }
    }

    //Function to check if an address is a user
    function isUser(address _user) public view returns(bool){
        for(uint i = 0; i < users.length; i++){
            if(users[i] == _user){
                return true;
            }
        }
        return false;
    }

    //Function to get all users
    function getAllUsers() external view returns(address[] memory){
        return users;
    }

    //Funciton to get user count
    function getUserCount() external view returns(uint){
        return users.length;
    }
}