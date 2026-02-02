echo "🔹 Setting Up k3d cluster"
if k3d cluster list | grep -q "iot"; then
    echo "K3d cluster "iot" already exists"
else
    echo "Creating k3d cluster..."
    k3d cluster create ${CLUSTER_NAME} --wait -p "8888:8888@loadbalancer"
fi

echo "Creating namespaces..."
for ns in "argocd" "dev"; do
    if ! kubectl get ns "$ns" >/dev/null 2>&1; then
        kubectl create ns $ns
    else
        echo "Namespace $ns already exists"
    fi
done

echo "Installing Argo CD..."
if ! kubectl get deployment argocd-server -n argocd >/dev/null 2>&1; then
  kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
else
  echo "Argo CD already installed, skipping"
fi

echo "🔹 Waiting for Argo CD to be ready"
kubectl rollout status deployment argocd-server -n argocd
kubectl apply -f ./confs/app.yaml

echo "Setup complete!"
