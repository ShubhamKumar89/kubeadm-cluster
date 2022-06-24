# kubeadm-cluster
Creating kubernetes cluster using `kubeadm` .

* If you want to create a `single node kubeadm cluster` then run the last command of the `cluster_start.sh`script i.e.

```
kubectl taint nodes --all  node-role.kubernetes.io/master-
```
## Also keep in mind to turn the swap off .
* Firstly check whether the swap is off by running the command 
```
sudo free -g
```
> If it shows 0 in the swap section then it is fine, otherwise run the following command:
```
sudo swapoff -a
```
**We are using flannel here as our CNI**
> flannel is a network fabric for containers, designed for Kubernetes.
