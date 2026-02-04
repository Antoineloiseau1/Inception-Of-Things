#!/bin/bash

GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RESET="\033[0m"

if command -v helm >/dev/null 2>&1; then
    echo -e "${YELLOW}Helm is already installed: $(helm version --short)${RESET}"
else
    echo -e "${YELLOW}Installing Helm...${RESET}"
    curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    echo -e "${GREEN}Helm installed: $(helm version --short)${RESET}"
fi