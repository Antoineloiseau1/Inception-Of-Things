#!/usr/bin/env bash
set -euo pipefail

echo "Cleaning up P3 environment..."

if k3d cluster list | grep -q "iot"; then
    echo "Deleting k3d cluster 'iot'..."
    k3d cluster delete iot
else
    echo "No k3d cluster 'iot' found"
fi


echo  "P3 environment cleaned!"
