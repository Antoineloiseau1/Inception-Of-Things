#! /bin/bash

curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644 --node-ip 192.168.56.110

kubectl apply -f /vagrant/apps/app1.yaml
kubectl apply -f /vagrant/apps/app2.yaml
kubectl apply -f /vagrant/apps/app3.yaml
kubectl apply -f /vagrant/apps/default-ingress.yaml
kubectl apply -f /vagrant/apps/ingress.yaml
