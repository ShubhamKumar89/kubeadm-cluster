# Single Node Kubeadm Cluster

```
git clone https://github.com/AdityaKoranga/kubeadm-cluster
cd kubeadm-cluster/
chmod +x single_node_cluster.sh
./single_node_cluster.sh
```

* If you want to create a `multi node kubeadm cluster` then remove the last command of the `single_node_cluster.sh` script i.e.

```
kubectl taint nodes --all node-role.kubernetes.io/master-
```

**We are using flannel as our CNI**

> flannel is a network fabric for containers, designed for Kubernetes.

## To delete Kubeadm CLuster

```
kubectl drain <node name> --delete-emptydir-data --force --ignore-daemonsets
sudo kubeadm reset
```
