// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";

contract DebugBankPrecompileScript is Script {
    address constant BANK_PRECOMPILE = 0x0000000000000000000000000000000000000804;
    
    function run() public {
        console.log("=== Debugging Bank Precompile ===");
        console.log("Precompile address:", BANK_PRECOMPILE);
 
        // Check if there's code at the precompile address
        uint256 codeSize;
        assembly {
            codeSize := extcodesize(BANK_PRECOMPILE)
        }
        console.log("Code size at precompile address:", codeSize);
        
        if (codeSize == 0) {
            console.log("No code found at precompile address - this chain might not have the Bank precompile");
            return;
        }
        
        // Try calling totalSupply() with low-level call
        console.log("Attempting to call totalSupply()...");
        (bool success, bytes memory data) = BANK_PRECOMPILE.staticcall(
            abi.encodeWithSignature("totalSupply()")
        );
        
        console.log("Call success:", success);
        console.log("Data length:", data.length);
        
        if (!success) {
            console.log("totalSupply() call failed");
            
            // Try to get revert reason
            if (data.length > 0) {
                console.log("Revert data:");
                console.logBytes(data);
            }
            
            // Maybe try a different method signature
            console.log("Trying different method signatures...");
            
            // Try balances() method instead
            (bool balancesSuccess, bytes memory balancesData) = BANK_PRECOMPILE.staticcall(
                abi.encodeWithSignature("balances(address)", address(this))
            );
            console.log("balances() call success:", balancesSuccess);
            console.log("balances() data length:", balancesData.length);
            
        } else {
            console.log("totalSupply() call succeeded!");
            console.logBytes(data);
        }
    }
}