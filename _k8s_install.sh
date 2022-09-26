#!/bin/bash

node_type=$1
master_ip=$2
k8s_version=1.25.0-00

function usage {
    echo "$0 [master] [master-ip] or [slave]"
    exit 1
}

if [ "$node_type" = "master" -a "$master_ip" = "" ]
then
	usage
elif [ "$node_type" != "master" -a "$node_type" != "slave" ] 
then
    usage
fi

sudo apt update && sudo apt install -y flex bison build-essential dwarves libssl-dev libelf-dev \
                    libnuma-dev pkg-config python3-pip python3-pyelftools \
                    libconfig-dev clang gcc-multilib uuid-dev sysstat
sudo pip3 install meson ninja

# Flush ip table
sudo iptables -F
sudo iptables-save

# Disable swap
sudo swapoff -a

# Enable iptables bridge
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sudo sysctl --system
sudo modprobe br_netfilter

sudo apt update
sudo apt install -y docker.io
sudo systemctl start docker && sudo systemctl enable docker
sudo docker -v
echo "====== please check whether docker is ready ======"

# Install go1.19
sudo apt-get purge golang*
mkdir -p download
cd download
wget https://golang.org/dl/go1.19.linux-amd64.tar.gz
tar -xvf go1.19.linux-amd64.tar.gz
# remove old go bin files
sudo rm -r /usr/local/go
# add new go bin files
sudo mv go /usr/local

GOROOT=/usr/local/go
echo "export GOROOT=/usr/local/go" >> ~/.bashrc
echo "export PATH=$PATH:$GOROOT/bin"  >>  ~/.bashrc
source ~/.bashrc
cd ~

# Install kubelet and kubeadm
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-kubeadm-kubelet-and-kubectl
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet=$k8s_version kubeadm=$k8s_version kubectl=$k8s_version
sudo apt-mark hold kubelet kubeadm kubectl

function deploy_k8s_master {
	# deploy kubernetes cluster
	sudo kubeadm init --apiserver-advertise-address=$master_ip --pod-network-cidr=10.244.0.0/16
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
}

if [ "$node_type" = "master" ] 
then
    deploy_k8s_master
fi

# For slaves, use the output emitted by "kubeadm init" to join the cluster,
# e.g.,
# sudo kubeadm join 128.110.218.67:6443 --token 2odkvh.i8ahh5ypnoozdwlx \
# --discovery-token-ca-cert-hash sha256:ee24f0b625a442ac832181cbf64adca1a15e1cbc66987cea5fca0dc832fd7b19

# To address the docker permission problem, run commands below:
# sudo groupadd docker
# sudo gpasswd -a $USER docker
# sudo newgrp docker
# docker version

echo "please source ~/.bashrc"
