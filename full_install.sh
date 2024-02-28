#!/bin/bash

read -p "CORE_IP: " CORE_IP
read -p "CORE_IP_PORT: " CORE_IP_PORT
read -p "CORE_GRPC_PORT: " CORE_GRPC_PORT

sudo apt update && sudo apt upgrade -y
sudo apt install curl tar wget aria2 clang pkg-config libssl-dev jq build-essential \
git make ncdu -y

ver="1.21.1"
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
git checkout tags/v0.12.4
make build
make install
make cel-key
celestia version

FULL_RPC_ADDR="0.0.0.0"
FULL_RPC_PORT="26658"
GATEWAY_ADDR="0.0.0.0"
GATEWAY_PORT="26659"

celestia full init \
  --p2p.network celestia \
  --core.ip $CORE_IP \
  --core.rpc.port $CORE_IP_PORT \
  --core.grpc.port $CORE_GRPC_PORT \
  --gateway \
  --gateway.addr $GATEWAY_ADDR \
  --gateway.port $GATEWAY_PORT \
  --rpc.addr $FULL_RPC_ADDR \
  --rpc.port $FULL_RPC_PORT

tee $HOME/celestia-full.service > /dev/null <<EOF
[Unit]
Description=celestia-full
After=network-online.target
[Service]
User=$USER
ExecStart=$(which celestia) full start --gateway --gateway.addr $GATEWAY_ADDR --gateway.port $GATEWAY_PORT --p2p.network celestia
Restart=on-failure
RestartSec=10
LimitNOFILE=infinity
[Install]
WantedBy=multi-user.target
EOF

sudo mv $HOME/celestia-full.service /etc/systemd/system/
sudo systemctl enable celestia-full
sudo systemctl daemon-reload

sudo systemctl start celestia-full && journalctl -u celestia-full -o cat -f