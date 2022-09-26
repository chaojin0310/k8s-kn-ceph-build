#!/bin/bash

# Install Knative CLI
cd ~/data
git clone https://github.com/knative/client.git
cd client
hack/build.sh -f
chmod +x kn
sudo mv kn /usr/local/bin
kn version
cd ~

# Install Knative Serving with yaml
# install the required custom resources
kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.7.1/serving-crds.yaml
# install the core components of Knative Serving
kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.7.1/serving-core.yaml
# install a networking layer, now we choose Kourier
# install the Knative Kourier controller
kubectl apply -f https://github.com/knative/net-kourier/releases/download/knative-v1.7.0/kourier.yaml
# configure Knative Serving to use Kourier by default
kubectl patch configmap/config-network \
  --namespace knative-serving \
  --type merge \
  --patch '{"data":{"ingress-class":"kourier.ingress.networking.knative.dev"}}'
# for self-building k8s clusters, external ip is not exposed properly
# configure the external ip manually, e.g.,
# kubectl patch svc kourier -n kourier-system -p '{"spec": {"type": "LoadBalancer", "externalIPs": ["128.110.218.122"]}}'
# fetch the External IP or CNAME
kubectl --namespace kourier-system get service kourier
# verify the installation
kubectl get pods -n knative-serving


# # Install Knative Eventing with yaml
# # install the required custom resource definitions (CRDs)
# kubectl apply -f https://github.com/knative/eventing/releases/download/knative-v1.7.1/eventing-crds.yaml
# # install the core components of Eventing
# kubectl apply -f https://github.com/knative/eventing/releases/download/knative-v1.7.1/eventing-core.yaml
# # verify the installation
# kubectl get pods -n knative-eventing

# # install a Channel (messaging) layer
# kubectl apply -f https://github.com/knative/eventing/releases/download/knative-v1.7.1/in-memory-channel.yaml

# # install a Broker layer
# kubectl apply -f https://github.com/knative/eventing/releases/download/knative-v1.7.1/mt-channel-broker.yaml
