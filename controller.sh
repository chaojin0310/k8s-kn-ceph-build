#!/bin/bash

controller_ip=$1

# deploy kubernetes cluster
sudo kubeadm init --apiserver-advertise-address=$controller_ip --pod-network-cidr=10.244.0.0/16
# for non-root user, make sure that kubernetes config directory has the same permissions as kubernetes config file.
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/
# deploy flannel
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/
# after this step, coredns status will be changed to running from pending
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
kubectl get nodes
kubectl get pods --all-namespaces

# For slaves, use the output emitted by "kubeadm init" to join the cluster,
# e.g.,
# sudo kubeadm join 128.110.218.67:6443 --token 2odkvh.i8ahh5ypnoozdwlx \
# --discovery-token-ca-cert-hash sha256:ee24f0b625a442ac832181cbf64adca1a15e1cbc66987cea5fca0dc832fd7b19
# or use 
# kubeadm token create --print-join-command
# to get the join command