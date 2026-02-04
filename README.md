# 42 Project: Inception-of-Things

## Objective
This project aims to deepen your knowledge by making you use K3d and K3s with
Vagrant. You will learn how to set up a personal virtual machine with Vagrant and the
distribution of your choice. Then, you will learn how to use K3s and its Ingress.
Last but not least, you will discover K3d that will simplify your life.
These steps will get you started with Kubernetes.


NB: The whole project has to be done in a virtual machine.

This project will consist of setting up several environments under specific rules.
It is divided into three parts you have to do in the following order:
- Part 1: K3s and Vagrant
- Part 2: K3s and three simple applications
- Part 3: K3d and Argo CD

## Concepts:
### K3s:
- **Lightweight Kubernetes distribution.**
- It packages the core Kubernetes components into a single binary and removes non-essential features such as legacy cloud providers and in-tree storage drivers. This makes it particularly well suited for local development, edge computing, CI environments, and small virtual machines where a full Kubernetes installation would be too heavy. Despite being lightweight, K3s exposes the same Kubernetes API and behavior as standard Kubernetes, which means applications and manifests created for K3s can be deployed unchanged to larger production clusters.
- Vagrant
- K3d
- CI and ArgoCD

## Glossaire :
- Kubernetes manifest: A manifest is a YAML (or JSON) file that describes the desired state of a Kubernetes resource.
