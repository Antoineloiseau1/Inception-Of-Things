#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

k3d cluster delete p3IngressCluster 2>/dev/null || true
k3d cluster create p3IngressCluster --agents 1 --wait \
  -p "80:80@loadbalancer" \
  -p "443:443@loadbalancer" \
  -p "8888:8888@loadbalancer"

kubectl config use-context k3d-p3IngressCluster >/dev/null 2>&1 || true
kubectl cluster-info

kubectl create namespace argocd 2>/dev/null || true
kubectl create namespace dev 2>/dev/null || true
kubectl get namespaces

echo "Installing ArgoCD"
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl -n argocd wait --for=condition=Available deploy --all --timeout=300s
kubectl -n argocd wait --for=condition=Ready pod --all --timeout=300s

kubectl -n argocd rollout status deploy/argocd-server
kubectl -n argocd rollout status deploy/argocd-repo-server
kubectl -n argocd rollout status statefulset/argocd-application-controller

echo "Applying Argo CD Ingress"
kubectl apply -f "$SCRIPT_DIR/../confs/argocd-ingress.yaml"


echo "Setting Argo CD external URL for ingress"
kubectl -n argocd patch configmap argocd-cm --type merge -p \
'{"data":{"url":"https://argocd.localhost"}}'

echo "Ensuring argocd-server runs with --insecure behind TLS-terminating ingress"
if kubectl -n argocd get deploy argocd-server -o jsonpath='{.spec.template.spec.containers[0].args}' | grep -q -- '--insecure'; then
  echo "--insecure already set"
else
  kubectl -n argocd patch deploy argocd-server --type='json' -p='[
    {"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--insecure"}
  ]'
fi

kubectl -n argocd rollout restart deploy/argocd-server
kubectl -n argocd rollout status deploy/argocd-server

echo "Argo CD initial admin password"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo

echo "Argo CD UI should be reachable at: https://argocd.localhost"
echo "If you browse from outside the VM, map the VM IP to argocd.localhost in your host /etc/hosts"