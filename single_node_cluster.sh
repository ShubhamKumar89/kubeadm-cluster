#!/bin/bash

set -xe

# Enable iptables for Bridge Traffic
sudo modprobe overlay
sudo modprobe br_netfilter

# Set up required sysctl params, these persist across reboots.
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system

# swap off
sudo swapoff -a
# Disable swap automatically at boot time
(crontab -l 2>/dev/null; echo "@reboot /sbin/swapoff -a") | crontab - || true

#install docker
sudo apt-get update && sudo apt-get upgrade -y
yes | sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
yes | sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

# post docker installation
# sudo groupadd docker
sudo usermod -aG docker $USER

sudo apt install docker-compose -y

# install kubectl, kubelet and kubeadm
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update 
sudo apt-get install -y kubelet=1.21.14-00 kubeadm=1.21.14-00 kubectl=1.21.14-00
sudo apt-mark hold kubelet kubeadm kubectl

# initialise kubeadm
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 

# to use kubectl to interact with cluster API
mkdir -p $HOME/.kube
echo "yes" | sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# flannel Network Plugin for Pod Networking
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

# To install the metrics server
kubectl apply -f https://raw.githubusercontent.com/techiescamp/kubeadm-scripts/main/manifests/metrics-server.yaml

#ONLY APPLICABLE FOR SINGLE NODE KUBEADM CLUSTER
kubectl taint nodes --all  node-role.kubernetes.io/master-