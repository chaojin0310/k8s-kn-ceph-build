# Performs a best effort revert of changes made by kubeadm init or kubeadm join
sudo kubeadm reset -f

rm -rf $HOME/.kube
sudo iptables -F && sudo iptables -X
sudo iptables -t nat -F && sudo iptables -t nat -X
sudo iptables -t raw -F && sudo iptables -t raw -X
sudo iptables -t mangle -F && sudo iptables -t mangle -X
sudo systemctl stop kubelet
sudo systemctl stop docker
# sudo rm -rf /var/lib/cni/
sudo rm -rf /var/lib/kubelet/*
# sudo rm -rf /etc/cni/

# sudo ifconfig cni0 down
sudo ifconfig flannel.1 down
sudo ifconfig docker0 down
# sudo ip link delete cni0
sudo ip link delete flannel.1
sudo systemctl start docker
sudo systemctl start kubelet

# # remake some components
# cd $GOPATH/src/k8s.io/kubernetes
# make WHAT="cmd/kubeadm"
# sudo mv $GOPATH/src/k8s.io/kubernetes/_output/bin/* /usr/local/bin