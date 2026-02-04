#!/usr/bin/env bash
set -euo pipefail

BLUE="\033[1;34m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
RESET="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GITLAB_NAMESPACE="gitlab"
GITLAB_SERVICE="gitlab-webservice-default"
GITLAB_URL="http://localhost:8929"  # VERIFY AT THE END ALL ENDPOINTS
GITHUB_REPO_URL="https://github.com/madem23/IoT-mdemma-ncardozo-anloisea.git"
PROJECT_NAME="inception-of-things"
PROJECT_NAMESPACE="gitlab"
TOKEN_NAME="automation-token"
TOKEN_EXPIRES_AT=$(date -d "+1 year" +%Y-%m-%d)


echo -e "${YELLOW}Waiting for GitLab to be ready...${RESET}"
kubectl rollout status deployment/$GITLAB_SERVICE -n $GITLAB_NAMESPACE #PROB DELETE, done in other script

echo -e "${YELLOW}Retrieving GitLab initial root password...${RESET}"
ROOT_PASSWORD=$(kubectl get secret gitlab-gitlab-initial-root-password -n $GITLAB_NAMESPACE -o jsonpath="{.data.password}" | base64 -d)
if [[ -z "$ROOT_PASSWORD" ]]; then
    echo "❌ Failed to get root password"
    exit 1
fi
echo -e "${GREEN}Retrieved initial root password${RESET}"

# Create root session to get temporary token
echo -e "${YELLOW}Creating root session...${RESET}"
SESSION_JSON=$(curl -s -X POST "$GITLAB_URL/api/v4/session" \
    -d "login=root" -d "password=$ROOT_PASSWORD")

ROOT_TOKEN=$(echo "$SESSION_JSON" | jq -r '.private_token')
if [[ -z "$ROOT_TOKEN" || "$ROOT_TOKEN" == "null" ]]; then
    echo "${RED}Failed to create root session or retrieve token${RESET}"
    exit 1
fi
echo -e "${GREEN}Root session created, temporary token acquired${RESET}"

# Create personal access token for automation
echo -e "${YELLOW}Creating personal access token for automation...${RESET}"
TOKEN_JSON=$(curl -s -X POST "$GITLAB_URL/api/v4/users/1/personal_access_tokens" \
    -H "PRIVATE-TOKEN: $ROOT_TOKEN" \
    -d "name=$TOKEN_NAME" \
    -d "scopes[]=api" \
    -d "expires_at=$TOKEN_EXPIRES_AT")

AUTO_TOKEN=$(echo "$TOKEN_JSON" | jq -r '.token')
if [[ -z "$AUTO_TOKEN" || "$AUTO_TOKEN" == "null" ]]; then
    echo "${BLUE}Failed to create personal access token. It might already exist.${RESET}"
    exit 1
fi
echo -e "${GREEN}Personal access token created successfully: $AUTO_TOKEN${RESET}"

# Import GitHub repo
echo -e "${YELLOW}Importing GitHub repo into GitLab...${RESET}"
curl -s -X POST "$GITLAB_URL/api/v4/projects/import" \
    -H "Authorization: Bearer $AUTO_TOKEN" \
    -F "name=$PROJECT_NAME" \
    -F "namespace=$PROJECT_NAMESPACE" \
    -F "import_url=$GITHUB_REPO_URL" \
    -F "visibility=private"

kubectl apply -f ${SCRIPT_DIR}/confs

echo -e "${GREEN}The GitHub repo is now imported into GitLab!${RESET}"

echo -e "${BLUE}To access ArgoCD's GUI, go to http://localhost:8080, login = admin, and enter the following password:${RESET}"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
kubectl port-forward svc/argocd-server -n argocd 8080:443

echo