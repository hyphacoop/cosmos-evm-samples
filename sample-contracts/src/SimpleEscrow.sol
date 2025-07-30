// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract SimpleEscrow {
    mapping(address => uint256) public balances;
    
    event Deposited(address indexed depositor, uint256 amount);
    event Withdrawn(address indexed withdrawer, address indexed recipient, uint256 amount);
    
    function deposit() public payable {
        require(msg.value > 0, "Must deposit more than 0");
        balances[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }
    
    function withdrawTo(address payable recipient) public {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No funds to withdraw");
        
        balances[msg.sender] = 0;
        recipient.transfer(amount);
        
        emit Withdrawn(msg.sender, recipient, amount);
    }
    
    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }
}

// Test contract in the same file
contract SimpleEscrowTest {
    SimpleEscrow public escrow;
    
    constructor() {
        escrow = new SimpleEscrow();
    }
    
    function testDeposit() public payable {
        uint256 depositAmount = 1 ether;
        
        // Test deposit
        escrow.deposit{value: depositAmount}();
        
        // Check balance
        require(escrow.getBalance() == depositAmount, "Deposit failed");
    }
    
    function testWithdraw() public payable {
        uint256 depositAmount = 1 ether;
        address payable recipient = payable(address(0x123));
        
        // Deposit first
        escrow.deposit{value: depositAmount}();
        
        // Record recipient balance before
        uint256 recipientBalanceBefore = recipient.balance;
        
        // Withdraw
        escrow.withdrawTo(recipient);
        
        // Check balances
        require(escrow.getBalance() == 0, "Withdrawal failed - escrow balance not zero");
        require(recipient.balance == recipientBalanceBefore + depositAmount, "Withdrawal failed - recipient didn't receive funds");
    }
    
    function testMultipleDeposits() public payable {
        uint256 firstDeposit = 0.5 ether;
        uint256 secondDeposit = 0.3 ether;
        
        escrow.deposit{value: firstDeposit}();
        escrow.deposit{value: secondDeposit}();
        
        require(escrow.getBalance() == firstDeposit + secondDeposit, "Multiple deposits failed");
    }
    
    // Helper function to fund this test contract
    receive() external payable {}
}
