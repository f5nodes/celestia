#!/bin/bash

read -p "Do you want to enable sending metrics to localhost:4318 (celestia-collector endpoint)? (y/n): " enable_metrics

if [ "$enable_metrics" = "y" ]; then
    metrics_flags="--metrics --metrics.endpoint localhost:4318 --metrics.tls=false"
else
    metrics_flags=""
fi

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

celestia light init

sudo tee <<EOF >/dev/null /etc/systemd/system/celestia-lightd.service
[Unit]
Description=celestia-lightd light node
After=network-online.target

[Service]
User=$USER
ExecStart=$(which celestia) light start --keyring.accname my_celes_key $metrics_flags
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable celestia-lightd
sudo systemctl daemon-reload
sudo systemctl start celestia-lightd && journalctl -u celestia-lightd -o cat -f