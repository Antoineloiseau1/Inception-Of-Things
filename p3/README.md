# P3: K3d and Argo CD

## Objectives:

- Set up a K3d Kubernetes cluster on a VM (using Docker) and create two namespaces: one for Argo CD and one (dev) for an application.
- Install Argo CD to automatically deploy an app from a public GitHub repository. 
- **The goal is to demonstrate continuous deployment, where changes pushed to GitHub are reflected in your cluster automatically.**

Purpose:
- We push a new Deployment YAML to GitHub.
- Argo CD detects the change and updates the Kubernetes cluster (in your dev namespace) automatically.
Essentially, our Git repo becomes the “single source of truth” for the cluster state.

## Key concepts:

- **K3d** runs K3s inside Docker containers, so it required Docker on host. It can run multiple clusters per host, vs. 1/installation for K3s.

- **Argo CD** is a continuous deployment tool for Kubernetes: it monitors a Git repository containing Kubernetes manifests or Helm charts, and automatically syncs the cluster state with the repository (GitOps approach).

- **namespace**: In Kubernetes, namespaces provide a mechanism for isolating groups of resources within a single cluster. Names of resources need to be unique within a namespace, but not across namespaces. Namespaces help isolate resources and avoid conflicts. Here, we set up 2 namespaces:
  - **argocd:** holds Argo CD system resources
  - **dev:** holds our development application (playground app).


## Resources :
### Local :

#### app.yaml:
- Purpose: Connects our Git repository to Argo CD.
- Action: Argo CD monitors this repo and automatically applies all Kubernetes manifests in it.

### On remote Git repository:
#### 1. deployment.yaml:
- Purpose: Defines how the application runs.
- Action: 
  - Creates Pods via a Deployment, sets container image that will be deployed (here wil42/playground:v1 or v2), replicas, and ports.
  - Set the Pod container port to 8888

#### 2. service.yaml:
- Purpose: Exposes Pods internally.
- Action: Allows other Pods (or Ingress) to reach the application, maps an external port to the Pod’s containerPort: its port 8888 -> to Pod container port 8888.

#### No ingress.yaml required here (only one app)

## To run:

#### 1. Installing prerequisites:
- `bash scripts/install.sh`

#### 2. Creating a K3d cluster, installing Argo CD and creating two namespaces: argocd and dev, applying app.yaml (connect ArgoCD to repo):
- `bash scripts/setup-cluster.sh`
- To check namespaces creation: `kubectl get ns`

#### 3. Testing:

- Testing: `kubectl get pods -n dev`
`kubectl get ns`
- Debugging:
```
kubectl get pods -n argocd
kubectl get applications -n argocd
kubectl describe application dev-app -n argocd
kubectl describe pod <POD-NAME> -n dev
```

To check service, IP and port : `kubectl get svc -n dev`

To access argoCD's GUI:
- To expose argo's port: `kubectl port-forward svc/argocd-server -n argocd 8080:443`
- To generate first password for login with 'admin': `kubectl -n arg    ocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`

To access app in browser:
- http://localhost:8888


#### 4. Managing app versions:

- Change image name in Repo's deployment.yaml, commit and push.
- Check in ArgoCD web GUI if updated.


