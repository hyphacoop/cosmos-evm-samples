
# Cosmos EVM Public Testnet

The public testnet provides a test environment for the latest cosmos/evm tag.

* **Chain ID**: `test-evm-1`
* **Denom**: `atest`
* **Current version**: [`v0.4.1`](https://github.com/cosmos/evm/releases/tag/v0.4.1)
* **Genesis file:**  [genesis.json](genesis.json), verify with ` shasum -a 256 genesis.json`
* **Genesis sha256sum**: `1b70d313fb495fc3dd5d786e6b74a7615d7098f73a3f33dbdfab5179e655671f`

## How to Join

The [script](./join-evm.sh) provided in this repo will install an evmd service on your machine.
* The script must be run either as root or from a sudoer account.
* The script will build a binary from the cosmos/evm repo.
* The script will sync via state sync.

## Block Explorers

* [Cosmos](https://explorer.polypore.xyz/test-evm-1) (Ping.pub)
* [EVM](https://evm.explorer.polypore.xyz/) (Blockscout)


## Endpoints

### Peers

* `f15ecadc8c0cd41ebc12598fd8b564ed2904f8fd@sentry-01.evm.polypore.xyz:26656`

### RPC

* `https://rpc.sentry-01.evm.polypore.xyz`

### EVM RPC

* `https://evmrpc.sentry-01.evm.polypore.xyz`

### API

* `https://rest.sentry-01.evm.polypore.xyz`

### gRPC

* `sentry-01.evm.polypore.xyz:9090`

### State sync

* `https://rpc.sentry-01.evm.polypore.xyz`

## Faucet

* Visit `faucet.polypore.xyz` to request tokens and check your address balance.

## Validator Setup

Follow the steps below to create a validator in the testnet.

1. Create a self-delegation account.
```
evmd keys add validator
```
This will output a `cosmos` address, its public key, and a mnemonic. Save the mnemonic in a safe place.

2. Fund the self-delegation account.
   
Go to `https://faucet.polypore.xyz/request?address=<self-delegation-account>&chain=test-evm-1` to get some funds sent to your account. Enter the address from the previous step instead of `<self-delegation-account>`.

3. Obtain your validator public key.
```
evmd comet show-validator
{"@type":"/cosmos.crypto.ed25519.PubKey","key":"BShP2dtw02I/1SnLp/D/RBHoeEaG3NqlMkwWYZOqcug="}
```

4. Create a validator JSON (`validator.json`) file.

Replace the `pubkey` value from the `show-validator` command above and edit the other values for your needs.
```
{
  "pubkey": {"@type":"/cosmos.crypto.ed25519.PubKey","key":"BShP2dtw02I/1SnLp/D/RBHoeEaG3NqlMkwWYZOqcug="},
  "amount": "1000000000000000atest",
  "moniker": "my-evm-validator",
  "identity": null,
  "website": null,
  "security": null,
  "details": null,
  "commission-rate": "0.1",
  "commission-max-rate": "0.2",
  "commission-max-change-rate": "0.01",
  "min-self-delegation": "1000000"
}
```

5. Submit the `create-validator` transaction.

```bash
evmd tx staking create-validator \
validator.json \
--from <self-delegation-account> \
--gas auto \
--gas-adjustment 3 \
--gas-prices 0.001uoki \
--yes
```

6. Verify the validator was created.

You can confirm the validator was created with the following command:
```
evmd q staking validators -o json | jq '.validators[] | select(.consensus_pubkey.value=="<pubkey value>")'
```
Using the example above, we would query the validator with:
```
evmd q staking validators -o json | jq '.validators[] | select(.consensus_pubkey.value=="BShP2dtw02I/1SnLp/D/RBHoeEaG3NqlMkwWYZOqcug=")'
```
