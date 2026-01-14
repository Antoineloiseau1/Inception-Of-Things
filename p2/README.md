# Understanding Kubernetes Resources
## Before we write any code, let me explain the 3 main Kubernetes resources you'll create:
1. #### Deployment
Think of it as a **recipe** that tells K3s: 
- Which container image to run (e.g., nginxdemos/hello)
How many copies (**replicas**) to run.

- It manages the pods (running containers) for you

2. #### Service
Acts as a stable **internal network endpoint** for your deployment:

- Deployments can restart/change, but the Service IP stays the same
Other pods use the Service name to communicate (like DNS)
Think of it as a load balancer inside your cluster

3. #### Ingress
The **traffic router** from outside world → your services:

Reads the HTTP HOST header (app1.com, app2.com)
Routes requests to the correct Service
K3s includes Traefik ingress controller by default

## Understanding the flow
`Request → Ingress (reads HOST) → Service (app1-service:80) → Pod (container:80)`

**Key concept**: The selector with app: app1 is how Service finds its Pods!

The **selector mechanism** is crucial: the Service finds Pods using the label `app: appX`