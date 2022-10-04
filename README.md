# Build a Kubernetes cluster with Knative and Ceph

## 1. Start up a X-node cluster on Cloudlab (X>=4)

1. The following steps require a **bash** environment. Please configure the default shell in your CloudLab account to be bash. For how to configure bash on Cloudlab, Please refer to the post "Choose your shell": https://www.cloudlab.us/portal-news.php?idx=49
2. When starting a new experiment on Cloudlab, select the **small-lan** profile
3. In the profile parameterization page, - Set **Number of Nodes** as **X** - Set OS image as **Ubuntu 20.04** - Set physical node type as **xI170** - Set **Link Speed** as **10Gb/s** - Please check **Temp Filesystem Max Space** - Keep **Temporary Filesystem Mount Point** as default (**/mydata**)
4. Wait for the cluster to be initialized (It may take 5 to 10 minutes)
5. Clone this repository on every node `git clone https://github.com/chaojin0310/scripts.git` and go to the root directory of the repository.

## 2. Partition the extra disk

Run `./partition.sh` at each node. The **partition.sh** script will reboot the server. 

*Note that this step is needed to perform **only once** after the cluster starts, no matter the node is rebooted or reloaded.*

## 3. Mount the smaller partition at ~/data

Run `./mount.sh` at each node after the node finishes rebooting.

*If you reload the server, you need to start from this step.*

## 4. Set up the environment

1. Run `./env_setup.sh` at each node. This script will flush the IP table, install docker and a recent release of **go** and so on to prepare for the installation of **Kubernetes** and **Knative**.
2. Run `source ~/.bashrc` to activate some necessary environment variables.
3. *If you require to compile **Knative** manually, you have to close current remote connection to the server and reconnect to it. Then run `docker login` to configure a DockerHub account.*

## 5. Install Kubernetes and Build a k8s cluster

1. Run `./k8s_build.sh` at each node. This script compiles k8s from its source code (release-1.25). The `make` process will last for about 10 minutes. You could also reference to `k8s_install.sh` to install some k8s tools using **apt**.
2. Choose a node as your k8s cluster controller. 
3. At the controller node, run `./controller.sh <controller_ip>`, where `<controller_ip>` is the public IP address of the controller node.
4. At other nodes, run `sudo kubeadm join <controller_ip> --token <token> --discovery-token-ca-cert-hash <hash>` after the controller has been intialized. The `kubeadm join` command is generated at the controller node.

### Rebuild the k8s cluster

If you want to modify some k8s code and remake it, run `./k8s_rebuild.sh` at each node (you need to add some components that need to be remaked in the script first). Then start from step `./controller.sh <controller_ip>`.

## 6. Install Knative Serving

Run `./kn_install.sh` at the controller node.

*If you need to compile Knative manually, please refer to `kn_build.sh`*.

## 7. Install Ceph Object Storage

1. Run `./ceph_install.sh` at the controller node.
2. Run `source ~/.bashrc` after the ceph cluster finishes initialization.

---
# Build a Ceph object storage on top of a Kubernetes cluster

## 1. Start up a X-node cluster on Cloudlab (X>=4)

## 2. Partition the extra disk

## 3. Mount the smaller partition at ~/data

## 4. Install k8s and build a cluster

1. Run `./k8s_install.sh master <controller_ip>` at the controller node and run `./k8s_install.sh slave` at other nodes. 
2. At other nodes, run `sudo kubeadm join <controller_ip> --token <token> --discovery-token-ca-cert-hash <hash>` after the controller has been intialized. The `kubeadm join` command is generated at the controller node.
3. Run `source ~/.bashrc` at all nodes.

## 5. Install Ceph Object Storage

1. Run `./ceph_install.sh` at the controller node.
2. Run `source ~/.bashrc` after the ceph cluster finishes initialization.
