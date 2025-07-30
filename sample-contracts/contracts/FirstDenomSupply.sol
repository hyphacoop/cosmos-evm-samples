// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import the Bank precompile interface
interface IBank {
    struct Balance {
        address contractAddress;
        uint256 amount;
    }
    
    function totalSupply() external view returns (Balance[] memory totalSupply);
}

contract FirstDenomSupply {
    // Bank precompile address
    address constant BANK_PRECOMPILE = 0x0000000000000000000000000000000000000804;
    
    IBank private bankPrecompile;
    
    constructor() {
        bankPrecompile = IBank(BANK_PRECOMPILE);
    }
    
    /// @dev Returns the total supply of the first denomination in the system
    /// @return amount The total supply amount of the first denom
    /// @return contractAddress The ERC20 contract address of the first denom
    function getFirstDenomSupply() external view returns (uint256 amount, address contractAddress) {
        IBank.Balance[] memory supplies = bankPrecompile.totalSupply();
        
        require(supplies.length > 0, "No denominations found");
        
        return (supplies[0].amount, supplies[0].contractAddress);
    }
    
    /// @dev Returns the total number of denominations in the system
    /// @return count The number of different denominations
    function getDenomCount() external view returns (uint256 count) {
        IBank.Balance[] memory supplies = bankPrecompile.totalSupply();
        return supplies.length;
    }
}