#!/bin/bash

IP_ADDRESS="192.168.56.110"
DOMAINS=("app1.com" "app2.com" "app3.com")

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)."
   exit 1
fi


for DOMAIN in "${DOMAINS[@]}"; do
    if grep -qP "^\s*$IP_ADDRESS\s+.*\b$DOMAIN\b" /etc/hosts; then
        echo "[SKIP] $DOMAIN is already correctly mapped to $IP_ADDRESS."
    else
        if grep -qP "\b$DOMAIN\b" /etc/hosts; then
            echo "[WARN] $DOMAIN was found with a different IP. Cleaning old entry..."
            sed -i "/\b$DOMAIN\b/d" /etc/hosts
        fi

        # 3. Append the clean mapping
        echo "[ADD] Mapping $DOMAIN to $IP_ADDRESS..."
        echo "$IP_ADDRESS $DOMAIN" >> /etc/hosts
    fi
done