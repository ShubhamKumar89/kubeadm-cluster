#!/bin/babsh

set -xe

#THIS IS FOR SINGLE NODE KUBEADM CLUSTER

#initialisation
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

mkdir -p $HOME/.kube
  yes | sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

# SWAPOFF
sudo swapoff -a

#flannel
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
#ONLY APPLICABLE FOR SINGLE NODE 
kubectl taint nodes --all  node-role.kubernetes.io/master-
