// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MultiSigOwnershipVerifier{
    //Struct to store multi-signature wallet information
    struct MultiSigWallet{
        address[] owners;
        uint256 requiredConfirmations;
        bool exists;
    }

    //Mapping from wallet address to its information
    mapping(address => MultiSigWallet) private wallets;

    //Event to log wallet registration
    event WalletRegistered(address walletAddress, address[] owners, uint256 requiredConfirmations);

    //Function to Registred New Wallet
    function registredWallet(address _walletAddress, address[] memory _owners, uint256 _requiredConfirmations) external {
        require(_walletAddress != address(0), "Invalid wallet address");
        require(_owners.length > 0, "At least one owner required");
        require(_requiredConfirmations > 0 && _requiredConfirmations <= _owners.length, "Invalid number of required confirmation");

        wallets[_walletAddress] = MultiSigWallet({
        owners: _owners,
        requiredConfirmations: _requiredConfirmations,  // Remove named arguments here!
        exists: true
        });

        emit WalletRegistered(_walletAddress, _owners, _requiredConfirmations);
    }
}