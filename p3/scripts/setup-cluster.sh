echo "🔹 Creating k3d cluster"
k3d cluster create iot --wait

echo "🔹 Creating namespaces"
kubectl create namespace argocd || true
kubectl create namespace dev || true

echo "🔹 Installing Argo CD"
kubectl apply -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "🔹 Waiting for Argo CD to be ready"
kubectl rollout status deployment argocd-server -n argocd

echo "Setup complete!"
echo "Run: kubectl port-forward svc/argocd-server -n argocd 8080:443"