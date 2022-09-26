#!/bin/bash

# DOCKER CONFIGURATION NEEDED!

# tmp solution
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
# echo "export PATH=$PATH:$GOPATH/bin" >> ~/.bashrc
# sudo gpasswd -a ${USER} docker
# echo "export KO_DOCKER_REPO=docker.io/chaojin0310/" >> ~/.bashrc
# ---
cd ~/data
git clone https://github.com/knative/client.git
cd client
hack/build.sh -f
chmod +x kn
sudo mv kn /usr/local/bin
kn version

go install github.com/google/ko@latest

cd ~/data
git clone -b release-1.7 https://github.com/knative/serving.git
cd serving
kubectl apply -f ./third_party/cert-manager-latest/cert-manager.yaml
kubectl wait --for=condition=Established --all crd
kubectl wait --for=condition=Available -n cert-manager --all deployments

ko apply --selector knative.dev/crd-install=true -Rf config/core/
kubectl wait --for=condition=Established --all crd
ko apply -Rf config/core/

# optional
ko delete -f config/post-install/default-domain.yaml --ignore-not-found
ko apply  -f config/post-install/default-domain.yaml

# kubectl -n knative-serving get pods

kubectl apply -f ./third_party/kourier-latest/kourier.yaml
kubectl patch configmap/config-network \
  -n knative-serving \
  --type merge \
  -p '{"data":{"ingress.class":"kourier.ingress.networking.knative.dev"}}'
  
# Recovery:
# ko delete --ignore-not-found=true  -Rf config/core/ -f ./third_party/kourier-latest/kourier.yaml -f ./third_party/cert-manager-latest/cert-manager.yaml

# mkdir -p ${GOPATH}/src/knative.dev
# cd ${GOPATH}/src/knative.dev
# git clone -b release-1.7 https://github.com/knative/eventing.git
# cd eventing
# ko apply -f config/
# ko apply -f config/channels/in-memory-channel/
# ko apply -f config/brokers/mt-channel-broker/
# ko apply -f test/config/sugar.yaml
# # Cleanup: ko delete -f config/
