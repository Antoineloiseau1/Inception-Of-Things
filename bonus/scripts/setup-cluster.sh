#!/bin/bash

# Colors
BLUE="\033[1;34m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
RESET="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${YELLOW}Setting Up k3d cluster ${RESET}"
if k3d cluster list | grep -q "iot"; then
    echo "K3d cluster "iot" already exists"
else
    echo "Creating k3d cluster..."
    k3d cluster create "iot" --wait -p "8888:8888@loadbalancer"
fi

echo -e "${YELLOW}\nCreating namespaces...${RESET}"
for ns in "argocd" "dev" "gitlab"; do
    if ! kubectl get ns "$ns" >/dev/null 2>&1; then
        kubectl create ns $ns
    else
        echo "Namespace $ns already exists"
    fi
done


echo -e "${YELLOW}\nAdding gitlab to helm repo...${RESET}"
helm repo add gitlab https://charts.gitlab.io
helm repo update
#helm install gitlab gitlab/gitlab \
 # --namespace gitlab \
  #-f ${SCRIPT_DIR}/../confs/gitlab.yaml

  helm upgrade --install gitlab gitlab/gitlab \
    --namespace gitlab \
    -f ${SCRIPT_DIR}/../confs/gitlab.yaml \
    --set global.hosts.domain=example.com \
    --set global.hosts.externalIP=10.10.10.10 \
    --set certmanager-issuer.email=me@example.com \
    --set global.hosts.https=false
kubectl get pods -n gitlab



echo -e "${YELLOW}\nInstalling Argo CD...${RESET}"
if ! kubectl get deployment argocd-server -n argocd >/dev/null 2>&1; then
  kubectl create -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
else
  echo "Argo CD already installed, skipping"
fi

echo -e "${YELLOW}\nWaiting for Argo CD to be ready${RESET}"
kubectl rollout status deployment argocd-server -n argocd
kubectl apply -f ${SCRIPT_DIR}/../confs

echo -e "${GREEN}\nSetup complete!\n${RESET}"

#echo -e "${BLUE}To access ArgoCD's GUI, go to http://localhost:8080, login = admin, and enter the following password:${RESET}"

#kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d


#kubectl port-forward svc/argocd-server -n argocd 8080:443


kubectl -n gitlab get secret gitlab-gitlab-initial-root-password \
  -o jsonpath="{.data.password}" | base64 -d
echo
kubectl port-forward svc/gitlab-webservice-default -n gitlab 8929:8181
