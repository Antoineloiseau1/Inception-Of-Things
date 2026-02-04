#!/bin/bash

BLUE="\033[1;34m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
RESET="\033[0m"

GITLAB_URL="http://gitlab.localhost:8081"
GITHUB_REPO="https://github.com/madem23/IoT-mdemma-ncardozo-anloisea.git"
PROJECT_NAME="IoT-Bonus"

echo -e "${YELLOW}Seeding GitLab with GitHub repository${RESET}"

TOKEN=$(kubectl exec deploy/gitlab-toolbox -n gitlab -- gitlab-rails runner 'user = User.find_by_username("root"); user.personal_access_tokens.find_by(name: "seed-script")&.delete; t = user.personal_access_tokens.create(name: "seed-script", scopes: ["api", "write_repository"], expires_at: 1.year.from_now); t.save; puts t.token' 2>/dev/null)

if curl -sf --header "PRIVATE-TOKEN: $TOKEN" "${GITLAB_URL}/api/v4/projects/root%2F${PROJECT_NAME}" > /dev/null 2>&1; then
  echo "Project already exists, skipping..."
else
  echo -e "${YELLOW}Creating empty project...${RESET}"

  RESPONSE=$(curl -s --header "PRIVATE-TOKEN: $TOKEN" \
    --header "Content-Type: application/json" \
    --request POST \
    --data "{\"name\": \"${PROJECT_NAME}\", \"visibility\": \"public\"}" \
    "${GITLAB_URL}/api/v4/projects")

  if echo "$RESPONSE" | grep -q '"id"'; then
    echo -e "${GREEN}Project created successfully${RESET}"


    echo -e "${YELLOW}Mirroring GitHub repository to GitLab...${RESET}"
    TEMP_DIR=$(mktemp -d)
    git clone --bare "$GITHUB_REPO" "$TEMP_DIR"
    cd "$TEMP_DIR"
    git push --mirror "http://root:${TOKEN}@gitlab.localhost:8081/root/${PROJECT_NAME}.git"
    cd - > /dev/null
    rm -rf "$TEMP_DIR"

    echo -e "${GREEN}Repository mirrored successfully${RESET}"
  else
    echo -e "${RED}Failed to create project:${RESET}"
    echo "$RESPONSE"
  fi
fi

echo -e "${GREEN}\nDone! Check: ${GITLAB_URL}/root/${PROJECT_NAME}\n${RESET}"
