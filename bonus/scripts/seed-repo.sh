#!/bin/bash

GITLAB_URL="http://gitlab.localhost"
GITHUB_REPO="https://github.com/madem23/IoT-mdemma-ncardozo-anloisea.git"
PROJECT_NAME="IoT-mdemma-ncardozo-anloisea"

echo "🔹 Seeding GitLab with GitHub repository"

TOKEN=$(kubectl exec deploy/gitlab-toolbox -n gitlab -- gitlab-rails runner 'user = User.find_by_username("root"); user.personal_access_tokens.find_by(name: "seed-script")&.delete; t = user.personal_access_tokens.create(name: "seed-script", scopes: ["api", "write_repository"], expires_at: 1.year.from_now); t.save; puts t.token' 2>/dev/null)

# Check if project exists, create if not
if curl -sf --header "PRIVATE-TOKEN: $TOKEN" "${GITLAB_URL}/api/v4/projects/root%2F${PROJECT_NAME}" > /dev/null 2>&1; then
  echo "Project already exists, skipping..."
else
  curl -s --header "PRIVATE-TOKEN: $TOKEN" -X POST "${GITLAB_URL}/api/v4/projects" \
    -d "name=${PROJECT_NAME}&visibility=public&import_url=${GITHUB_REPO}"
fi

echo "✅ Done! Check: ${GITLAB_URL}/root/${PROJECT_NAME}"
