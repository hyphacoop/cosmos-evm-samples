# SimpleEscrow Contract

This is a smart contract with three methods: `deposit()`, `withdrawToAddress(adress payable recipient)`, and `getBalance()`
We will:
* Deploy the contract
* Make a deposit
* Check the balance
* Withdraw the funds

## Deploy

* Create a new project
```
forge init escrow-project
cd escrow-project
```

* Copy [SimpleEscrow.sol](SimpleEscrow.sol) to the `src` folder.
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

## Execute

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