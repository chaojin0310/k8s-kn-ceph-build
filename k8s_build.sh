#!/bin/bash

cd ~/download
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.25.0/crictl-v1.25.0-linux-amd64.tar.gz
tar -xvf crictl-v1.25.0-linux-amd64.tar.gz
sudo mv crictl /usr/bin
sudo apt install -y socat conntrack
sudo mkdir -p /opt/cni/bin
curl -L "https://github.com/containernetworking/plugins/releases/download/v1.1.1/cni-plugins-linux-amd64-v1.1.1.tgz" | sudo tar -C "/opt/cni/bin" -xz

# Make Kubernetes
mkdir -p $GOPATH/src/k8s.io
cd $GOPATH/src/k8s.io
git clone -b release-1.25 https://github.com/kubernetes/kubernetes
cd kubernetes
./hack/install-etcd.sh
export PATH="$GOPATH/src/k8s.io/kubernetes/third_party/etcd:${PATH}"
make

sudo mv $GOPATH/src/k8s.io/kubernetes/_output/bin/* /usr/local/bin
DOWNLOAD_DIR="/usr/local/bin"
sudo mkdir -p "$DOWNLOAD_DIR"
RELEASE_VERSION="v0.4.0"
curl -sSL "https://raw.githubusercontent.com/kubernetes/release/${RELEASE_VERSION}/cmd/kubepkg/templates/latest/deb/kubelet/lib/systemd/system/kubelet.service" | sed "s:/usr/bin:${DOWNLOAD_DIR}:g" | sudo tee /etc/systemd/system/kubelet.service
sudo mkdir -p /etc/systemd/system/kubelet.service.d
curl -sSL "https://raw.githubusercontent.com/kubernetes/release/${RELEASE_VERSION}/cmd/kubepkg/templates/latest/deb/kubeadm/10-kubeadm.conf" | sed "s:/usr/bin:${DOWNLOAD_DIR}:g" | sudo tee /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
sudo systemctl enable --now kubelet
