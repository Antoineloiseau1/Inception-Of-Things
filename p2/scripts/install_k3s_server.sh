#! /bin/bash

curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644 --node-ip 192.168.56.110

kubectl apply -f /vagrant/confs/app1.yaml
kubectl apply -f /vagrant/confs/app2.yaml
kubectl apply -f /vagrant/confs/app3.yaml
kubectl apply -f /vagrant/confs/default-ingress.yaml
kubectl apply -f /vagrant/confs/ingress.yaml
