# MyCoin Contract

This is a smart contract that uses OpenZeppelin's ERC20 implementation to create a supply of a new token. You can find the list of methods [here](https://docs.openzeppelin.com/contracts/5.x/api/token/erc20#ERC20).

We will:
* Install the OpenZeppelin library
* Deploy the contract
* Check the total supply
* Query the ERCO20 token name and symbol
* Transfer funds to another account

## Deploy

* Create a new project
```
forge init mycoin-project
cd mycoin-project
```
* Copy [MyCoin.sol](MyCoin.sol) to the `src` folder.
* Place your private key in a variable
```
ETH_PRIV_KEY=$(evmd keys unsafe-export-eth-key my-wallet)
```
* Install the OpenZeppelin contracts library
```
forge install OpenZeppelin/openzeppelin-contracts
```
* Create the contract
```
forge create src/MyCoin.sol:MyCoin --private-key $ETH_PRIV_KEY --constructor-args 1000001000000000000000000
```
* Broadcast the transaction
```
forge create src/MyCoin.sol:MyCoin --private-key $ETH_PRIV_KEY --broadcast --constructor-args 1000001000000000000000000
```
The `Deployed to` field represents the contract address. Export it to a variable so we can use it in the next section:
```
CONTRACT_ADDR=<"Deployed to" address>
```

## Execute

### Query the total supply

```
supply=$(cast call $CONTRACT_ADDR 'totalSupply()') ; cast decode-abi 'totalSupply()(uint256)' $supply
```

### Query the token name and symbol
```
name=$(cast call $CONTRACT_ADDR 'name()') ; cast decode-abi 'name()(string)' $name
```
```
symbol=$(cast call $CONTRACT_ADDR 'symbol()') ; cast decode-abi 'symbol()(string)' $symbol
```

### Transfer funds to another address

* Set the `RECIPIENT` variable: `RECIPIENT=0xD611A140d8a87D398214A181C9dE7Ebe0e8a8b71`
```
cast send $CONTRACT_ADDR "transfer(address,uint256)" $RECIPIENT 1000000000000 --private-key $ETH_PRIV_KEY
```

### Query an address balance
* With foundry's `cast`
```
balance=$(cast call $contract 'balanceOf(address)' $RECIPIENT) ; cast decode-abi 'balanceOf(address)(uint256)' $balance
```
* With `evmd`
```
evmd q evm balance-erc20 $RECIPIENT $CONTRACT_ADDR
```