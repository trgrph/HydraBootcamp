// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CryptoBank {

    struct Account {
        address payable accountOwner; // Owner of the cryptobank account
        uint accountBalance;  // Balance of the cryptobank account
        uint creationDate; // Creation date the of the cryptobank account
        bool active; // Status of the cryptobank account
        LockStatus lock; 
    }

    struct Loan {
        uint loanedAmount;
        uint dueDate;
    }

    enum LockStatus { UNLOCKED, LOCKED }
    LockStatus public lockStatus;

    mapping (address => Account) public accounts;

    modifier onlyActiveAccounts {
        require(accounts[msg.sender].active == true, "Account must be active.");
        _;
    }

    function createAccount() public {
        require(accounts[msg.sender].active == false, "Account is already active.");
        Account memory account;
        account.accountOwner = payable(msg.sender);
        account.accountBalance = 0; // Defaults to 0. 
        account.creationDate = block.timestamp; 
        account.active = true;
        account.lock = LockStatus.UNLOCKED;
        accounts[msg.sender] = account; 
    }

    function depositFunds() public payable onlyActiveAccounts {
        accounts[msg.sender].accountBalance += msg.value;
    }

    function withdrawFunds(uint _amount) public payable onlyActiveAccounts {
        require(accounts[msg.sender].lock == LockStatus.UNLOCKED, "Account must be unlocked.");
        require(accounts[msg.sender].accountBalance >= _amount, "Not enough funds to withdraw this amount.");
        accounts[msg.sender].accountOwner.transfer(_amount);
        accounts[msg.sender].accountBalance -= msg.value;
    }

    function checkBalance() public view returns (uint) {
        require(msg.sender == accounts[msg.sender].accountOwner, "Only the owner of an account can check its balance.");
        return accounts[msg.sender].accountBalance;
    }

    function transferFunds(address payable _to, uint _amount) public onlyActiveAccounts {
        require(msg.sender == accounts[msg.sender].accountOwner, "Only the owner of an account can transfer funds.");
        require(accounts[msg.sender].lock == LockStatus.UNLOCKED, "Account must be unlocked.");
        require(accounts[msg.sender].accountBalance >= _amount, "Not enough funds to transfer this amount.");
        _to.transfer(_amount);
        accounts[msg.sender].accountBalance -= _amount;
    }

    function closeAccount() public onlyActiveAccounts {
        require(msg.sender == accounts[msg.sender].accountOwner, "Only the owner of an account can close an account.");
        accounts[msg.sender].accountOwner.transfer(accounts[msg.sender].accountBalance);
        accounts[msg.sender].active = false;
    }

    function lockAccount() public {
        require(accounts[msg.sender].lock == LockStatus.UNLOCKED, "Account must be unlocked.");
        accounts[msg.sender].lock = LockStatus.LOCKED;
    }

    function unlockAccount() public {
        require(accounts[msg.sender].lock == LockStatus.LOCKED, "Account must be locked.");
        accounts[msg.sender].lock = LockStatus.UNLOCKED;
    }

    function getBankLiquidity() public view returns (uint) {
            return address(this).balance;
    }

}
