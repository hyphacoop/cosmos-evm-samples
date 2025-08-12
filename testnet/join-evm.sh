#!/bin/bash
# Set up an evmd service to join the public testnet.

# Configuration
# You should only have to modify the values in this block
# ***
NODE_HOME=~/.evmd
NODE_MONIKER=evmd-test
SERVICE_NAME=evmd
CHAIN_VERSION=v1.0.0-rc2
DENOM=atest
GAS_PRICE=0$DENOM
# ***

CHAIN_BINARY='evmd'
CHAIN_ID=test-evm-1
GENESIS_URL=https://raw.githubusercontent.com/hyphacoop/cosmos-evm-samples/refs/heads/main/testnet/genesis.json
PEERS="f15ecadc8c0cd41ebc12598fd8b564ed2904f8fd@sentry-01.evm.polypore.xyz:26656"
SYNC_RPC_1=https://rpc.sentry-01.evm.polypore.xyz:443
SYNC_RPC_2=https://rpc.sentry-01.evm.polypore.xyz:443
TRUST_OFFSET=6000
SYNC_RPC_SERVERS="$SYNC_RPC_1,$SYNC_RPC_2"

echo "> Installing curl, jq, and wget."
sudo apt-get install curl jq wget -y

echo "> Adding binaries to path."
mkdir -p $HOME/go/bin
export PATH=$PATH:$HOME/go/bin

echo "> Installing evmd binary."
echo "Installing go..."
rm go*linux-amd64.tar.gz
wget https://go.dev/dl/go1.24.2.linux-amd64.tar.gz
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.24.2.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
sudo apt install build-essential -y
cd $HOME
rm -rf evm
git clone https://github.com/cosmos/evm.git
pushd evm
git checkout $CHAIN_VERSION
make install
popd

echo "> Initializing $NODE_HOME directory."
rm -rf $NODE_HOME
$CHAIN_BINARY config set client chain-id $CHAIN_ID --home $NODE_HOME
$CHAIN_BINARY config set client keyring-backend test --home $NODE_HOME
$CHAIN_BINARY init $NODE_MONIKER --chain-id $CHAIN_ID --home $NODE_HOME
sed -i -e "/minimum-gas-prices =/ s^= .*^= \"$GAS_PRICE\"^" $NODE_HOME/config/app.toml
sed -i -e "s/persistent_peers = \"\"/persistent_peers = \"$PEERS\"/" $NODE_HOME/config/config.toml

echo "> Configuring state sync."
CURRENT_BLOCK=$(curl -s $SYNC_RPC_1/block | jq -r '.result.block.header.height')
TRUST_HEIGHT=$[$CURRENT_BLOCK-$TRUST_OFFSET]
TRUST_BLOCK=$(curl -s $SYNC_RPC_1/block\?height\=$TRUST_HEIGHT)
TRUST_HASH=$(echo $TRUST_BLOCK | jq -r '.result.block_id.hash')
sed -i -e '/enable =/ s/= .*/= true/' $NODE_HOME/config/config.toml
sed -i -e '/trust_period =/ s/= .*/= "24h0m0s"/' $NODE_HOME/config/config.toml
sed -i -e "/trust_height =/ s/= .*/= $TRUST_HEIGHT/" $NODE_HOME/config/config.toml
sed -i -e "/trust_hash =/ s/= .*/= \"$TRUST_HASH\"/" $NODE_HOME/config/config.toml
sed -i -e "/rpc_servers =/ s^= .*^= \"$SYNC_RPC_SERVERS\"^" $NODE_HOME/config/config.toml

echo "> Replacing genesis file."
wget $GENESIS_URL -O genesis.json
mv genesis.json $NODE_HOME/config/genesis.json

echo "> Setting up evmd service."
sudo rm /etc/systemd/system/$SERVICE_NAME.service
sudo touch /etc/systemd/system/$SERVICE_NAME.service

echo "[Unit]"                               | sudo tee /etc/systemd/system/$SERVICE_NAME.service
echo "Description=evmd service"             | sudo tee /etc/systemd/system/$SERVICE_NAME.service -a
echo "After=network-online.target"          | sudo tee /etc/systemd/system/$SERVICE_NAME.service -a
echo ""                                     | sudo tee /etc/systemd/system/$SERVICE_NAME.service -a
echo "[Service]"                            | sudo tee /etc/systemd/system/$SERVICE_NAME.service -a
echo "User=$USER"                           | sudo tee /etc/systemd/system/$SERVICE_NAME.service -a
echo "ExecStart=$HOME/go/bin/$CHAIN_BINARY start --home $NODE_HOME --json-rpc.api eth,txpool,personal,net,debug,web3" | sudo tee /etc/systemd/system/$SERVICE_NAME.service -a
echo "Restart=no"                           | sudo tee /etc/systemd/system/$SERVICE_NAME.service -a
echo "LimitNOFILE=4096"                     | sudo tee /etc/systemd/system/$SERVICE_NAME.service -a
echo ""                                     | sudo tee /etc/systemd/system/$SERVICE_NAME.service -a
echo "[Install]"                            | sudo tee /etc/systemd/system/$SERVICE_NAME.service -a
echo "WantedBy=multi-user.target"           | sudo tee /etc/systemd/system/$SERVICE_NAME.service -a

# Start service
echo "> Starting $SERVICE_NAME.service"
sudo systemctl daemon-reload
sudo systemctl enable $SERVICE_NAME.service
sudo systemctl start $SERVICE_NAME.service
sudo systemctl restart systemd-journald

echo "> Setting up path for binary bin."
echo "export PATH=$PATH:/$HOME/go/bin" >> .profile

echo "***********************"
echo "To see the chain log enter:"
echo "journalctl -fu $SERVICE_NAME.service"
echo "***********************"

$CHAIN_BINARY version --long