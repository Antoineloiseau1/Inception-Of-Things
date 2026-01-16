#!/bin/bash

IP="172.18.0.2"
HOSTNAME="playground.local"

LINE="$IP $HOSTNAME"

echo "🔹 Adding $HOSTNAME to /etc/hosts"

# Check if entry already exists
if grep -q "$HOSTNAME" /etc/hosts; then
  echo "✅ Entry already exists in /etc/hosts"
else
  echo "$LINE" | sudo tee -a /etc/hosts > /dev/null
  echo "✅ Entry added: $LINE"
fi
