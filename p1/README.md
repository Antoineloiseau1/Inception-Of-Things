# P1: K3s and Vagrant

## Objective:
Set up 2 machines run by Vagrant:
- **Server**: Kubernetes control plane. This is the brain of the cluster. It runs the components that decide what should run and where. We'll install K3s in *controller mode*.
- **ServerWorker**: Kubernetes worker node. This machine is responsible for actually running our applications inside containers. When the control plane decides to start or stop containers, it sends instructions to ServerWorker. We'll install K3s in *agent mode*: this machine joins the cluster and waits for the Server to tell it what workloads to run.

NB: K3s is a lightweight Kubernetes distribution designed for environments with limited resources.

### Summary:
K3s turns the 2 VMs provided by Vagrant into a Kubernetes cluster: the Server machine controls the cluster, the ServerWorker executes workloads, and kubectl is the tool we'll use to interact with the cluster from the command line.

## To launch vagrant and connect to machines
If needed: `vagrant destroy -f && rm -rf .vagrant`
`vagrant up`
`vagrant ssh anloiseaS`
`vagrant ssh anloiseaSW`

## To test configuration
`vagrant status`
`vagrant global-status` to see all Vagrant machines on the system
`get nodes -o wide`
`ifconfig eth1`
`ip a`
`ip a show eth1`
