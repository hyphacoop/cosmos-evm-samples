// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../contracts/FirstDenomSupply.sol";

contract FirstDenomSupplyForkTest is Test {
    FirstDenomSupply public firstDenomSupply;
    
    // Bank precompile address
    address constant BANK_PRECOMPILE = 0x0000000000000000000000000000000000000804;
    
    function setUp() public {
        // Deploy our contract
        firstDenomSupply = new FirstDenomSupply();
    }
    
    function testGetFirstDenomSupplyOnLiveChain() public {
        console.log("Testing against live chain data...");
        
        // Get the count first to see what we're working with
        uint256 denomCount = firstDenomSupply.getDenomCount();
        console.log("Total denominations found:", denomCount);
        
        if (denomCount > 0) {
            (uint256 amount, address contractAddress) = firstDenomSupply.getFirstDenomSupply();
            
            console.log("First denomination:");
            console.log("  Contract Address:", contractAddress);
            console.log("  Total Supply:", amount);
            
            // Basic sanity checks
            assertTrue(amount > 0, "Supply should be greater than 0");
            assertTrue(contractAddress != address(0), "Contract address should not be zero");
        } else {
            console.log("No denominations found on this chain");
        }
    }
    
    function testBankPrecompileDirectly() public {
        console.log("Testing Bank precompile directly...");
        
        // Call the precompile directly
        (bool success, bytes memory data) = BANK_PRECOMPILE.staticcall(
            abi.encodeWithSignature("totalSupply()")
        );
        
        if (success) {
            console.log("Bank precompile call successful");
            console.log("Data length:", data.length);
            
            // Try to decode if we got data
            if (data.length > 0) {
                // This might fail if the return format is different than expected
                try this.decodeTotalSupply(data) {
                    console.log("Successfully decoded totalSupply response");
                } catch {
                    console.log("Could not decode totalSupply response - format might be different");
                    console.logBytes(data);
                }
            }
        } else {
            console.log("Bank precompile call failed");
        }
    }
    
    // Helper function to decode totalSupply response
    function decodeTotalSupply(bytes memory data) external pure {
        // This is just for testing - the actual decoding
        abi.decode(data, (IBank.Balance[]));
    }
}