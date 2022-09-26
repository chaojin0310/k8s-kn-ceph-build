#!/bin/bash

sudo apt update && sudo apt install -y flex bison build-essential dwarves libssl-dev libelf-dev \
                    libnuma-dev pkg-config python3-pip python3-pyelftools \
                    libconfig-dev clang gcc-multilib uuid-dev sysstat
sudo pip3 install meson ninja

# Flush ip table
sudo iptables -F
sudo iptables-save

# Disable swap
sudo swapoff -a
cat /etc/fstab | grep -v '^#' | grep -v 'swap' | sudo tee /etc/fstab

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
sudo gpasswd -a $USER docker
# docker version
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

cd ~
GOROOT=/usr/local/go
GOPATH=$HOME/data/go
echo "export GOROOT=$GOROOT" >> ~/.bashrc
echo "export GOPATH=$HOME/data/go" >> ~/.bashrc
echo "export KO_DOCKER_REPO=docker.io/chaojin0310/" >> ~/.bashrc
echo "export PATH=$PATH:$GOROOT/bin:$GOPATH/bin" >> ~/.bashrc
# source ~/.bashrc
echo "please source ~/.bashrc"
echo "please reconnect the server and then docker login!!!"
