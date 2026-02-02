#!/usr/bin/env bash

set -euo pipefail

echo "Installing tools on $(whoami)..."

sudo apt-get update -y
sudo apt-get install -y curl ca-certificates gnupg lsb-release git

echo "Tool 1: Docker..."
if command -v docker >/dev/null 2>&1; then
    sudo systemctl enable --now docker
else
    curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
    sudo sh /tmp/get-docker.sh
    rm -f /tmp/get-docker.sh
    sudo systemctl enable --now docker
fi
sudo usermod -aG docker "$USER" || true

echo "Tool 2: kubectl..."
curl -fsLO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm -f kubectl
echo "kubectl installed/updated: $(kubectl version --client=true --short 2>/dev/null || true)"

echo "Tool 3: k3d..."
curl -fsSL https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
echo "k3d installed/updated: $(k3d version | head -n 1 || true)"

echo "Tool 4: argocd"
curl -fsSL -o /tmp/argocd-linux-amd64 \
  https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x /tmp/argocd-linux-amd64
sudo install -m 555 /tmp/argocd-linux-amd64 /usr/local/bin/argocd
rm -f /tmp/argocd-linux-amd64
argocd version --client

echo "Tools correctly installed on $(whoami) :)"
echo "Note: you must logout/login or open a new shell for docker group changes"