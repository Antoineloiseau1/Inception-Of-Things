#!/bin/bash
SERVER_IP="192.168.56.110"
TOKEN_FILE="/vagrant/node-token"

# Wait for the server to write the file
while [ ! -f "$TOKEN_FILE" ]; do
  echo "Waiting for $TOKEN_FILE..."
  sleep 5
done

K3S_TOKEN=$(cat "$TOKEN_FILE")

curl -sfL https://get.k3s.io | K3S_URL=https://"$SERVER_IP":6443 K3S_TOKEN="$K3S_TOKEN" sh -s - agent --node-ip="192.168.56.111"
