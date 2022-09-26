#!/bin/bash

# admission controller
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.7.1/cert-manager.yaml

# rook
cd ~/data
git clone --single-branch --branch v1.10.1 https://github.com/rook/rook.git
cd rook/deploy/examples
kubectl create -f crds.yaml -f common.yaml -f operator.yaml
kubectl create -f cluster.yaml

# toolbox
kubectl create -f toolbox.yaml
kubectl -n rook-ceph rollout status deploy/rook-ceph-tools

# object storage (s3-like)
kubectl create -f object.yaml
kubectl create -f storageclass-bucket-delete.yaml
kubectl create -f object-bucket-claim-delete.yaml

cd ~

# client connection
echo "export AWS_HOST=$(kubectl -n default get cm ceph-delete-bucket -o jsonpath='{.data.BUCKET_HOST}')" >> ~/.bashrc
echo "export PORT=$(kubectl -n default get cm ceph-delete-bucket -o jsonpath='{.data.BUCKET_PORT}')" >> ~/.bashrc
echo "export BUCKET_NAME=$(kubectl -n default get cm ceph-delete-bucket -o jsonpath='{.data.BUCKET_NAME}')" >> ~/.bashrc
echo "export AWS_ACCESS_KEY_ID=$(kubectl -n default get secret ceph-delete-bucket -o jsonpath='{.data.AWS_ACCESS_KEY_ID}' | base64 --decode)" >> ~/.bashrc
echo "export AWS_SECRET_ACCESS_KEY=$(kubectl -n default get secret ceph-delete-bucket -o jsonpath='{.data.AWS_SECRET_ACCESS_KEY}' | base64 --decode)" >> ~/.bashrc
echo "please source ~/.bashrc"
