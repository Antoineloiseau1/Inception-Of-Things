# P3: K3d and Argo CD

## Objectives:

- Set up a K3d Kubernetes cluster on a VM (using Docker) and create two namespaces: one for Argo CD and one (dev) for an application.
- Install Argo CD to automatically deploy an app from a public GitHub repository. 
- **The goal is to demonstrate continuous deployment, where changes pushed to GitHub are reflected in your cluster automatically.**

## Key concepts:
- **K3d** runs K3s inside Docker containers, so it required Docker on host. It can run multiple clusters per host, vs. 1/installation for K3s.
- **Argo CD** is a continuous deployment tool for Kubernetes: it monitors a Git repository containing Kubernetes manifests or Helm charts, and automatically syncs the cluster state with the repository (GitOps approach).

Example:
- We push a new Deployment YAML to GitHub.
- Argo CD detects the change and updates the Kubernetes cluster (in your dev namespace) automatically.

Essentially, our Git repo becomes the “single source of truth” for the cluster state.

## Summary of Steps


- Push your app YAMLs to GitHub.

- Configure Argo CD to deploy your app automatically to dev.

- Test CI by changing YAMLs in GitHub → Argo CD deploys automatically.

## To run:

#### 1. Installing prerequisites:
- `bash scripts/blablabla.sh`

#### 2. Creating a K3d cluster, installing Argo CD and creating two namespaces: argocd and dev:
- `bash scripts/setup-cluster.sh`
- To check namespaces creation: `kubectl get ns`

#### 3. Pushing our app YAMLs to our repo GITHUB:
- `bash scripts/add-hosts.sh`
- `kubectl apply -f https://raw.githubusercontent.com/madem23/IoT-mdemma-ncardozo-anloisea/main/app.yaml`

- Testing: `kubectl get pods -n dev`



