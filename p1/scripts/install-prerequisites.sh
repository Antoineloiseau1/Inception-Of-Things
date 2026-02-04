#!/bin/bash

set -e

YELLOW="\033[1;33m"
GREEN="\033[1;32m"
RED="\033[1;31m"
NC="\033[0m"

info() {
  echo -e "${YELLOW}[INFO] $1${NC}"
}

success() {
  echo -e "${GREEN}[OK] $1${NC}"
}

error() {
  echo -e "${RED}[ERROR] $1${NC}"
}

# ---------- Helpers ----------
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

file_exists() {
  [ -f "$1" ]
}

info "Installing Vagrant and VirtualBox"

# ---------- VAGRANT ----------
if command_exists vagrant; then
  success "Vagrant already installed"
else
  info "Installing Vagrant"

  HASHICORP_KEYRING="/usr/share/keyrings/hashicorp-archive-keyring.gpg"
  HASHICORP_LIST="/etc/apt/sources.list.d/hashicorp.list"

  if ! file_exists "$HASHICORP_KEYRING"; then
    info "Adding HashiCorp GPG key"
    wget -qO- https://apt.releases.hashicorp.com/gpg \
      | sudo gpg --dearmor -o "$HASHICORP_KEYRING" \
      || { error "Failed to add HashiCorp GPG key"; exit 1; }
  else
    success "HashiCorp GPG key already exists"
  fi

  if ! file_exists "$HASHICORP_LIST"; then
    info "Adding HashiCorp APT repository"
    UBUNTU_CODENAME=$(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs)
    echo "deb [arch=$(dpkg --print-architecture) signed-by=$HASHICORP_KEYRING] https://apt.releases.hashicorp.com $UBUNTU_CODENAME main" \
      | sudo tee "$HASHICORP_LIST" >/dev/null \
      || { error "Failed to add HashiCorp APT repo"; exit 1; }
  else
    success "HashiCorp APT repo already exists"
  fi

  info "Updating APT and installing Vagrant"
  sudo apt update
  sudo apt install -y vagrant

  success "Vagrant installed successfully"
fi

# ---------- VIRTUALBOX ----------
if command_exists VBoxManage; then
  success "VirtualBox already installed"
else
  info "Installing VirtualBox"

  VBOX_KEYRING="/usr/share/keyrings/oracle-virtualbox-2016.gpg"
  VBOX_LIST="/etc/apt/sources.list.d/virtualbox.list"

  if ! file_exists "$VBOX_KEYRING"; then
    info "Adding VirtualBox GPG key"
    wget -qO- https://www.virtualbox.org/download/oracle_vbox_2016.asc \
      | sudo gpg --dearmor --yes --output "$VBOX_KEYRING" \
      || { error "Failed to add VirtualBox GPG key"; exit 1; }
  else
    success "VirtualBox GPG key already exists"
  fi

  if ! file_exists "$VBOX_LIST"; then
    info "Adding VirtualBox APT repository"
    echo "deb [arch=amd64 signed-by=$VBOX_KEYRING] https://download.virtualbox.org/virtualbox/debian bookworm contrib" \
      | sudo tee "$VBOX_LIST" >/dev/null \
      || { error "Failed to add VirtualBox APT repo"; exit 1; }
  else
    success "VirtualBox APT repo already exists"
  fi

  info "Updating APT and installing VirtualBox"
  sudo apt update
  sudo apt install -y virtualbox-7.0

  success "VirtualBox installed successfully"
fi

success "Vagrant and VirtualBox installation completed"
