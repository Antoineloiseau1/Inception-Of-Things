#!/bin/bash
set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

STABLE_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)

# 2. Check if kubectl is already in PATH and matches version
KUBECTL_PATH=$(command -v kubectl || echo "/usr/local/bin/kubectl")
SHOULD_DOWNLOAD=true

# Helper for logging
info() { echo "${BLUE}[INFO] $1${NC}"; }
success() { echo "${GREEN}[SUCCESS] $1${NC}"; }
warn() { echo "${YELLOW}[WARN] $1${NC}"; }
error() { echo "${RED}[ERROR] $1${NC}"; }

info "Starting idempotent Docker installation for $(whoami)..."

info "Updating package index..."
sudo apt update -y

info "Ensuring ca-certificates and curl are installed..."
sudo apt install -y ca-certificates curl

sudo install -m 0755 -d /etc/apt/keyrings
if [ ! -f /etc/apt/keyrings/docker.asc ]; then
    info "Downloading Docker GPG key..."
    sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
else
    success "Docker GPG key is already present. Skipping download."
fi

if [ ! -f /etc/apt/sources.list.d/docker.sources ]; then
    info "Adding Docker repository to /etc/apt/sources.list.d/..."
    sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF
    info "Refreshing package index with new Docker source..."
    sudo apt update -y
else
    success "Docker repository is already configured. Skipping setup."
fi

if ! command -v docker &> /dev/null; then
    info "Installing Docker Engine and Compose plugin..."
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
else
    success "Docker binaries found: $(docker --version). Skipping installation."
fi

info "Enabling and starting Docker service via systemctl..."
sudo systemctl enable --now docker

if ! getent group docker > /dev/null; then
    info "Creating 'docker' system group..."

    sudo groupadd docker
fi

if ! groups "$USER" | grep -q "\bdocker\b"; then
    info "Adding user $USER to the docker group for passwordless access..."
    sudo usermod -aG docker "$USER"
    newgrp docker
    warn "PERMISSIONS UPDATED: You must run 'newgrp docker' manually after this script finishes."
else
    success "User $USER already has docker permissions. No changes needed."
fi

if command -v docker &> /dev/null; then
    success "Docker installation and configuration is complete!"
    info "Next step: Try running 'docker ps' to verify connection to the daemon."
else
    error "Installation failed. The 'docker' command was not found in PATH."
    exit 1
fi

if ! command -v k3d &> /dev/null; then
    info "Installing k3d..."
    INSTALL_SCRIPT=$(mktemp /tmp/k3d_install.XXXXXX.sh)
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh -o "$INSTALL_SCRIPT"
    chmod +x "$INSTALL_SCRIPT"
    bash "$INSTALL_SCRIPT"
    rm "$INSTALL_SCRIPT"
    success "k3d installed: $(k3d --version | head -n 1)"
else
    success "k3d already installed: $(k3d --version | head -n 1)"
fi


if command -v kubectl &> /dev/null; then
    # Extract version (handling the change in 'kubectl version' output format)
    CURRENT_VERSION=$(kubectl version --client --short 2>/dev/null | grep -o 'v[0-9]\+\.[0-9]\+\.[0-9]\+' || echo "none")
    
    if [[ "$CURRENT_VERSION" == "$STABLE_VERSION" ]]; then
        success "kubectl $STABLE_VERSION is already installed in PATH."
        SHOULD_DOWNLOAD=false
    fi
fi

# 3. Download and Install if needed
if [ "$SHOULD_DOWNLOAD" = true ]; then
    info "Downloading kubectl $STABLE_VERSION..."
    curl -LO "https://dl.k8s.io/release/$STABLE_VERSION/bin/linux/amd64/kubectl"
    chmod +x kubectl
    
    info "Moving kubectl to /usr/local/bin..."
    sudo mv kubectl /usr/local/bin/kubectl
    success "kubectl installed successfully!"
fi