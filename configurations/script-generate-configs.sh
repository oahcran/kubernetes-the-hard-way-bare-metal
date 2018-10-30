#!/bin/bash
set -e

export KUBERNETES_PUBLIC_ADDRESS=172.18.30.20

export KUBERNETES_MASTERS_IP_ADDRESSES=172.18.30.21,172.18.30.22,172.18.30.23

export WOKRER_NODE_1_NAME=k8s-worker-1
export WOKRER_NODE_1_IP=172.18.30.31

export WOKRER_NODE_2_NAME=k8s-worker-2
export WOKRER_NODE_2_IP=172.18.30.32

export WOKRER_NODE_3_NAME=k8s-worker-3
export WOKRER_NODE_3_IP=172.18.30.33

# Service Cluster IP Address
export KUBERNETES_SERVICE_INTERNAL_ADDRESS=10.32.0.1

## Certificate Authority
cfssl gencert -initca ca-csr.json | cfssljson -bare ca

### The Kubernetes API Server Certificate

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=${KUBERNETES_SERVICE_INTERNAL_ADDRESS},${KUBERNETES_MASTERS_IP_ADDRESSES},${KUBERNETES_PUBLIC_ADDRESS},127.0.0.1,kubernetes.default \
  -profile=kubernetes \
  kubernetes-csr.json | cfssljson -bare kubernetes

### The Admin Client Certificate

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  admin-csr.json | cfssljson -bare admin

### The Kubelet Client Certificates

for instance in ${WOKRER_NODE_1_NAME} ${WOKRER_NODE_2_NAME} ${WOKRER_NODE_3_NAME}; do
cat > ${instance}-csr.json <<EOF
{
  "CN": "system:node:${instance}",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Dallas",
      "O": "system:nodes",
      "OU": "Kubernetes The Hard Way Bare Metal",
      "ST": "Texas"
    }
  ]
}
EOF
done

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=${WOKRER_NODE_1_NAME},${WOKRER_NODE_1_IP} \
  -profile=kubernetes \
  ${WOKRER_NODE_1_NAME}-csr.json | cfssljson -bare ${WOKRER_NODE_1_NAME}


cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=${WOKRER_NODE_2_NAME},${WOKRER_NODE_2_IP} \
  -profile=kubernetes \
  ${WOKRER_NODE_2_NAME}-csr.json | cfssljson -bare ${WOKRER_NODE_2_NAME}

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=${WOKRER_NODE_3_NAME},${WOKRER_NODE_3_IP} \
  -profile=kubernetes \
  ${WOKRER_NODE_3_NAME}-csr.json | cfssljson -bare ${WOKRER_NODE_3_NAME}


##

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-proxy-csr.json | cfssljson -bare kube-proxy


cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-controller-manager-csr.json | cfssljson -bare kube-controller-manager

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-scheduler-csr.json | cfssljson -bare kube-scheduler

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  service-account-csr.json | cfssljson -bare service-account


## Validating DNS
openssl x509 -in kubernetes.pem -text | grep "DNS:"

openssl x509 -in ${WOKRER_NODE_1_NAME}.pem -text | grep "DNS:"

openssl x509 -in ${WOKRER_NODE_2_NAME}.pem -text | grep "DNS:"

openssl x509 -in ${WOKRER_NODE_3_NAME}.pem -text | grep "DNS:"


##

for instance in ${WOKRER_NODE_1_NAME} ${WOKRER_NODE_2_NAME} ${WOKRER_NODE_3_NAME}; do
  kubectl config set-cluster k8s-the-hard-way-metal \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=${instance}.kubeconfig

  kubectl config set-credentials system:node:${instance} \
    --client-certificate=${instance}.pem \
    --client-key=${instance}-key.pem \
    --embed-certs=true \
    --kubeconfig=${instance}.kubeconfig

  kubectl config set-context default \
    --cluster=k8s-the-hard-way-metal \
    --user=system:node:${instance} \
    --kubeconfig=${instance}.kubeconfig

  kubectl config use-context default --kubeconfig=${instance}.kubeconfig
done

## kube-proxy.kubeconfig
kubectl config set-cluster k8s-the-hard-way-metal \
  --certificate-authority=ca.pem \
  --embed-certs=true \
  --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config set-credentials system:kube-proxy \
  --client-certificate=kube-proxy.pem \
  --client-key=kube-proxy-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config set-context default \
  --cluster=k8s-the-hard-way-metal \
  --user=system:kube-proxy \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig

## kube-controller-manager.kubeconfig
kubectl config set-cluster k8s-the-hard-way-metal \
  --certificate-authority=ca.pem \
  --embed-certs=true \
  --server=https://127.0.0.1:6443 \
  --kubeconfig=kube-controller-manager.kubeconfig

kubectl config set-credentials system:kube-controller-manager \
  --client-certificate=kube-controller-manager.pem \
  --client-key=kube-controller-manager-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-controller-manager.kubeconfig

kubectl config set-context default \
  --cluster=k8s-the-hard-way-metal \
  --user=system:kube-controller-manager \
  --kubeconfig=kube-controller-manager.kubeconfig

kubectl config use-context default --kubeconfig=kube-controller-manager.kubeconfig

## kube-scheduler.kubeconfig
kubectl config set-cluster k8s-the-hard-way-metal \
  --certificate-authority=ca.pem \
  --embed-certs=true \
  --server=https://127.0.0.1:6443 \
  --kubeconfig=kube-scheduler.kubeconfig

kubectl config set-credentials system:kube-scheduler \
  --client-certificate=kube-scheduler.pem \
  --client-key=kube-scheduler-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-scheduler.kubeconfig

kubectl config set-context default \
  --cluster=k8s-the-hard-way-metal \
  --user=system:kube-scheduler \
  --kubeconfig=kube-scheduler.kubeconfig

kubectl config use-context default --kubeconfig=kube-scheduler.kubeconfig

## admin.kubeconfig
kubectl config set-cluster k8s-the-hard-way-metal \
  --certificate-authority=ca.pem \
  --embed-certs=true \
  --server=https://127.0.0.1:6443 \
  --kubeconfig=admin.kubeconfig

kubectl config set-credentials admin \
  --client-certificate=admin.pem \
  --client-key=admin-key.pem \
  --embed-certs=true \
  --kubeconfig=admin.kubeconfig

kubectl config set-context default \
  --cluster=k8s-the-hard-way-metal \
  --user=admin \
  --kubeconfig=admin.kubeconfig

kubectl config use-context default --kubeconfig=admin.kubeconfig

## ENCRYPTION_KEY
ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)

cat > encryption-config.yaml <<EOF
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ${ENCRYPTION_KEY}
      - identity: {}
EOF
