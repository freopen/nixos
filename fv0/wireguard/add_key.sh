#!/bin/sh

mkdir -p /tmp/wg-keys
chmod 700 /tmp/wg-keys

PRIVATE_KEY=$(nix shell nixpkgs#wireguard-tools -c wg genkey)
PUBLIC_KEY=$(echo $PRIVATE_KEY | nix shell nixpkgs#wireguard-tools -c wg pubkey)
SERVER_PUBLIC_KEY=$(cat server.pub)
KEY_NUMBER=$(($(cat client_keys.txt | wc -w)+2))

echo "
[Interface]
Address = 10.0.0.$KEY_NUMBER
PrivateKey = $PRIVATE_KEY
DNS = 1.1.1.1

[Peer]
PublicKey = $SERVER_PUBLIC_KEY
Endpoint = $1:51820
AllowedIPs = 0.0.0.0/0, ::0
" > /tmp/wg-keys/key$KEY_NUMBER.conf

nix run nixpkgs#zip -- -j /tmp/wg-keys/key$KEY_NUMBER.zip /tmp/wg-keys/key$KEY_NUMBER.conf
rm /tmp/wg-keys/key$KEY_NUMBER.conf

echo $PUBLIC_KEY >> client_keys.txt
