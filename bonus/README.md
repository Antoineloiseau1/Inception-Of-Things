# P3: GITLAB

## Objectives:

At the end of P3, we have a local Kubernetes cluster (k3d), with Argo CD installed inside it that deploys an application, accessed via port-forward or NodePort (NO ingress required).

For the BONUS, we are adding GitLab. It will:
- run locally
- be reachable from the host browser
- be the source for Argo CD to pull manifests from (vs. GitHub)

expose port gitlab 80:8181
