#!/bin/bash

read -p "CORE_IP: " CORE_IP
read -p "CORE_IP_PORT: " CORE_IP_PORT
read -p "CORE_GRPC_PORT: " CORE_GRPC_PORT

sudo apt update && sudo apt upgrade -y
sudo apt install curl tar wget aria2 clang pkg-config libssl-dev jq build-essential \
git make ncdu -y

ver="1.23.0"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile
source $HOME/.bash_profile
go version

cd $HOME
rm -rf celestia-node
git clone https://github.com/celestiaorg/celestia-node.git
cd celestia-node/
git checkout tags/v0.21.5
make build
make install
make cel-key
celestia version

FULL_RPC_ADDR="0.0.0.0"
FULL_RPC_PORT="26658"
GATEWAY_ADDR="0.0.0.0"
GATEWAY_PORT="26659"

celestia bridge init \
  --p2p.network celestia \
  --core.ip $CORE_IP \
  --core.rpc.port $CORE_IP_PORT \
  --core.grpc.port $CORE_GRPC_PORT \
  --gateway \
  --gateway.addr $GATEWAY_ADDR \
  --gateway.port $GATEWAY_PORT \
  --rpc.addr $BRIDGE_RPC_ADDR \
  --rpc.port $BRIDGE_RPC_PORT

tee $HOME/celestia-bridge.service > /dev/null <<EOF
[Unit]
Description=celestia-bridge
After=network-online.target
[Service]
User=$USER
ExecStart=$(which celestia) bridge start --gateway --gateway.addr $GATEWAY_ADDR --gateway.port $GATEWAY_PORT --p2p.network celestia
Restart=on-failure
RestartSec=10
LimitNOFILE=infinity
[Install]
WantedBy=multi-user.target
EOF

sudo mv $HOME/celestia-bridge.service /etc/systemd/system/
sudo systemctl enable celestia-bridge
sudo systemctl daemon-reload

sudo systemctl start celestia-bridge && journalctl -u celestia-bridge -o cat -f
