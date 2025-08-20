# Sample EVM Contracts

## Prerequisites

* [Set up Foundry](#foundry-setup)
* Create a wallet with `evmd`
```
evmd keys add my-wallet
```
* Fund the wallet with `atest` tokens
```
https://faucet.polypore.xyz/request?address=<wallet_address>&chain=test-evm-1
```

## Contracts

* [FirstDenomSupply](./FirstDenomSupply/)
  * Uses the `bank` precompile to query the total supply of the first denom.
* [SimpleEscrow](./SimpleEscrow/)
  * Implements a simple escrow account to deposit to and withdraw from.
* [MyCoin](./MyCoin/)
  * Demonstrates OpenZeppelin's ERC20 implementation.

### Foundry Setup

* Install [foundry](https://book.getfoundry.sh/)
* Configure the EVM testnet endpoints in `~/.foundry/foundry.toml`:
```
[rpc_endpoints]
cosmos = "https://rpc.sentry-01.evm.polypore.xyz:443"
[profile.default]
chain_id     = 262144
eth_rpc_url  = "https://evmrpc.sentry-01.evm.polypore.xyz:443"
evm_version  = "cancun"
```