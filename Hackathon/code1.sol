// Solidity Smart Contract for WhisperPay
// Deployable on Seismic Blockchain

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract WhisperPay is Ownable {
    IERC20 public stablecoin;
    mapping(address => bytes32) private balances;
    mapping(address => bytes32) private stealthAddresses;

    event EncryptedTransfer(address indexed sender, bytes32 recipient, uint256 encryptedAmount);
    event BalanceUpdated(address indexed user, bytes32 newBalance);
    event StealthAddressGenerated(address indexed user, bytes32 stealthAddress);

    constructor(address _stablecoin) {
        stablecoin = IERC20(_stablecoin);
    }
    
    function generateStealthAddress(bytes32 _stealthAddress) external {
        stealthAddresses[msg.sender] = _stealthAddress;
        emit StealthAddressGenerated(msg.sender, _stealthAddress);
    }

    function encryptedTransfer(bytes32 _recipient, uint256 _encryptedAmount, bytes32[] calldata _proof) external {
        require(MerkleProof.verify(_proof, balances[msg.sender], _recipient), "Invalid proof");
        emit EncryptedTransfer(msg.sender, _recipient, _encryptedAmount);
    }
    
    function updateBalance(bytes32 _newBalance) external {
        balances[msg.sender] = _newBalance;
        emit BalanceUpdated(msg.sender, _newBalance);
    }
}