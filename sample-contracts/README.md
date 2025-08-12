# Sample EVM Contracts

## Prerequisites

* [Set up Foundry](#set-up-foundry)
* Create a wallet with `evmd`
```
evmd keys add my-wallet
```
* Fund the wallet with `atest` tokens
```
https://faucet.polypore.xyz/request?address=<wallet_address>&chain=test-evm-1
```

## First Denom Supply

This is a smart contract with two methods. It uses the `bank` precompile to query the supply of Cosmos-native tokens on the chain. These are tokens that are accessible both via Cosmos SDK and the EVM.

### Deploy

* Create a new project
```
forge init denom-project
```

* Copy [FirstDenomSupply.sol](src/FirstDenomSupply.sol) to the `src` folder.
  * This is a smart contract with two methods. It uses the bank precompile to query the supply of Cosmos-native tokens on the chain.
* Place your private key in a variable
```
ETH_PRIV_KEY=$(evmd keys unsafe-export-eth-key my-wallet)
```
* Create the contract
```
forge create src/FirstDenomSupply.sol:FirstDenomSupply --private-key $ETH_PRIV_KEY
```
* Broadcast the transaction
```
forge create src/FirstDenomSupply.sol:FirstDenomSupply --private-key $ETH_PRIV_KEY --broadcast
```
The broadcast command will result in something like this:
```
[⠊] Compiling...
No files changed, compilation skipped
Deployer: 0x26B6dE909517e6583970DBF5F00FE80DC1dfdFE4
Deployed to: 0x5bd9D0adeA4FEBD25d190B64De8d2BAa8ff15a0C
Transaction hash: 0xf801a26d0824239898c2a0a5f17c57cc79e3822db664f04e8c709fcd3334dcb8
```
The `Deployed to` field represents the contract address. Export it to a variable so we can use it in the next section:
```
CONTRACT_ADDR=<"Deployed to" address>
```

### Execute

The contract has two methods: `getFirstDenomSupply()` and `getDenomCount()`. We will call the first one. It will return a `uint64`, indicating the total supply of that denom, and an Ethereum address, which is the ERC20 address for that denom in the EVM.

* Call `cast call` to run the `getFirstDenomSupply()` method
```
cast call $CONTRACT_ADDR 'getFirstDenomSupply()' --private-key $ETH_PRIV_KEY
```
This will return a glob of hex similar to this:
```
0x00000000000000000000000000000000000000000000000000000006fc4230e4000000000000000000000000ea1b9540ec1f2170718caff6f0083c966fffed0b
```
This is the hex-encoded binary response to the smart contract call. `cast` can decode it using the contract's signature:
```
cast decode-abi 'getFirstDenomSupply()(uint256 amount, address contractAddress)' 0x00000000000000000000000000000000000000000000000000000006fc4230e4000000000000000000000000ea1b9540ec1f2170718caff6f0083c966fffed0b
30002000100 [3e10]
0xEA1b9540eC1f2170718Caff6F0083C966fFFEd0B
```

These are the decoded contents of the hex string returned by `cast call`. The first line tells us there are `3e10` tokens, and the second line tells us this particular token has an address of `0xEA1b9540eC1f2170718Caff6F0083C966fFFEd0B`.

## Simple Escrow

This is a smart contract with three methods: `deposit()`, `withdrawToAddress(adress payable recipient)`, and `getBalance()`
We will:
* Deploy the contract
* Make a deposit
* Check the balance
* Withdraw the funds

### Deploy

* Create a new project
```
forge init escrow-project
```

* Copy [SimpleEscrow.sol](src/SimpleEscrow.sol) to the `src` folder.
  * This is a smart contract with two methods. It uses the bank precompile to query the supply of Cosmos-native tokens on the chain.
* Place your private key in a variable
```
ETH_PRIV_KEY=$(evmd keys unsafe-export-eth-key my-wallet)
```
* Create the contract
```
forge create src/SimpleEscrow.sol:SimpleEscrow --private-key $ETH_PRIV_KEY
```
* Broadcast the transaction
```
forge create src/FirstDenomSupply.sol:FirstDenomSupply --private-key $ETH_PRIV_KEY --broadcast
```
The `Deployed to` field represents the contract address. Export it to a variable so we can use it in the next section:
```
CONTRACT_ADDR=<"Deployed to" address>
```

### Execute

* Deposit funds to the contract
```
cast send $CONTRACT_ADDR 'deposit()' --value 1000000000000 --private-key $ETH_PRIV_KEY 
```
* Query the contract balance
```
cast call $CONTRACT_ADDR 'getBalance()' --private-key $ETH_PRIV_KEY
```
* Withdraw funds from the contract
```
cast send $CONTRACT_ADDR "withdrawTo(address)" <recipient address> --private-key $ETH PRIV_KEY
```

## Foundry Setup

* Install [foundry](https://book.getfoundry.sh/)
* Configure the EVM testnet endpoints in `~/.foundry/foundry.toml`:
```
[rpc_endpoints]
cosmos = "https://rpc.sentry-01.evm.polypore.xyz:443"
[profile.default]
chain_id     = 4221
eth_rpc_url  = "https://evmrpc.sentry-01.evm.polypore.xyz:443"
evm_version  = "istanbul"
```