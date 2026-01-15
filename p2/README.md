# P2: K3s and three simple applications

## Objective:
Setting up:
- Machines: 1 VM:
  - IP: 192.168.56.110
  - Hostname: anloiseauS
- Kubernetes: K3s in server mode
- Applications: 3 web apps (nginx)
- Pods / Deployments:
  - App1: 1 pod (replica = 1)
  - App2: 3 pods (replicas = 3)
  - App3: 1 pod (replica = 1, default app for ingress)
- Services: 1 Service per app to expose the pod(s)
- Ingress: 1 Ingress resource :
  - Routes requests based on Host header (app1.local, app2.local)
  - Default backend: App3 (used when no hostname is specified)
- Access: Requests to 192.168.56.110 with proper hostnames reach the correct app, or App3 by default

## Understanding Kubernetes Resources
### 3 main Kubernetes resources created:
1. #### Deployment
A *Deployment* is a Kubernetes object that manages a set of identical Pods.It ensures that a specified number of replicas of your app are always running.
Think of it as a **recipe** that tells K3s: 
- Which container image to run (e.g., nginxdemos/hello)
- How many copies (**replicas**) to run.
It manages the pods (running containers).
It will be set up through files.yaml.

2. #### Service

A *Service* is a Kubernetes object complementing *Deployments* that **exposes one or more Pods** so they can be accessed inside or outside the cluster.
- Enables internal communication between Pods (ClusterIP).
- Exposes apps outside the cluster if needed (NodePort, LoadBalancer).
- Pods are ephemeral: they can die or be replaced with new ones with different IPs.The Service acts as a stable **internal network endpoint** for our deployment. Deployments can restart/change, but the Service IP stays the same.

3. #### Ingress
An Ingress is a Kubernetes object that manages external access to Services, usually via HTTP/HTTPS. Unlike a Service, which exposes Pods at a fixed IP/port, Ingress lets you route traffic based on URL paths or hostnames.

It works with an Ingress controller (like Traefik, NGINX, etc.) that actually implements the routing. K3s includes Traefik ingress controller by default.

### How does it work?
- Someone opens a browser : `http://app1.local`
- The HTTP request reaches the VM’s IP (192.168.56.110) on port 80 (HTTP) with the HOST header:
```
GET / HTTP/1.1
Host: app1.local
```
- The Ingress controller (Traefik) looks at this header and checks the Ingress rules you defined (hostnames, paths) to decide which service to send the request to: Host: app1.local → goes to Service for App1

### Summary of the flow
`Request → Ingress (reads HOST) → Service (app1-service:80) → Pod (container:80)`

## Key concepts:
### Labels:
To identify Kubernetes objects (like pods).
```
metadata:
  labels:
    app: app1
```

### The selector:
A Service uses a selector to choose which Pods it should forward traffic to.
Ex in a service:
```
spec:
  selector:
    app: app1
```
The **selector mechanism** is crucial: when someone accesses the Service (via ClusterIP, NodePort, or Ingress):
- Kubernetes looks at the selector app=app1.
- Finds all Pods with that label.
- Sends traffic to them.
NB: If the Pod is deleted and a new one is created by the Deployment, it inherits the same label, so the Service automatically routes traffic to the new Pod.

## To run:
`vagrant up` (destroy pre-existing non necessary vagrant machines with vagrand destroy <ID>)
`vagrant ssh`
`ls /vagrant/apps` (on server VM) to see the files.yaml copied in the VM
Checking K3s resources are running:
`kubectl get nodes` (on server VM)
`kubectl get pods -A` (on server VM)
