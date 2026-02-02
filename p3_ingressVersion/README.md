# P3

This setup creates a k3d Kubernetes cluster, installs Argo CD, exposes the Argo CD UI using Ingress, and deploys an application in the dev namespace using GitOps.

The goal is to demonstrate that changing the application version in the Git repository automatically updates the running application via Argo CD.

Requirements

A Debian or Ubuntu based VM is assumed
Internet access is required to download tools and Argo CD manifests

Tools installed by the script

* Docker

* kubectl

* k3d

* argocd CLI

--------------------------------------------------------------------------------------

So the steps of this part are :

Install tools

Create the cluster and install Argo CD

Acces Argo CD UI

Register the GitOps app

Verify the app is running

Demosntrate Git Ops update v1 to v2

--------------------------------------------------------------------------------------

Difference between port forwarding and ingress method :

Port-forwarding is a kubectl tunnel used mainly for debugging and demos, 

while Ingress is a cluster-level HTTP routing mechanism used to expose services

in a more production-like way.

So this ingress version exposes services at the cluster level using an Ingress Controller (Trafik in k3s).

* The cluster listens on ports 80 and 443

* Traffic is routed based on hostname and path

* Argo CD is accessed like a real web service