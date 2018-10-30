#!/bin/bash
set -e

export KUBERNETES_PUBLIC_ADDRESS=172.18.30.20

export MASTER_1_NAME=k8s-master-1
export MASTER_1_IP=172.18.30.21

export MASTER_2_NAME=k8s-master-2
export MASTER_2_IP=172.18.30.22

export MASTER_3_NAME=k8s-master-3
export MASTER_3_IP=172.18.30.23

for instance in ${MASTER_1_NAME} ${MASTER_2_NAME} ${MASTER_3_NAME}; do
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
  -hostname=${MASTER_1_NAME},${MASTER_1_IP} \
  -profile=kubernetes \
  ${MASTER_1_NAME}-csr.json | cfssljson -bare ${MASTER_1_NAME}


cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=${MASTER_2_NAME},${MASTER_2_IP} \
  -profile=kubernetes \
  ${MASTER_2_NAME}-csr.json | cfssljson -bare ${MASTER_2_NAME}

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=${MASTER_3_NAME},${MASTER_3_IP} \
  -profile=kubernetes \
  ${MASTER_3_NAME}-csr.json | cfssljson -bare ${MASTER_3_NAME}


  openssl x509 -in ${MASTER_1_NAME}.pem -text | grep "DNS:"

  openssl x509 -in ${MASTER_2_NAME}.pem -text | grep "DNS:"

  openssl x509 -in ${MASTER_3_NAME}.pem -text | grep "DNS:"


  ##

  for instance in ${MASTER_1_NAME} ${MASTER_2_NAME} ${MASTER_3_NAME}; do
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

## Clean Up
#for instance in ${MASTER_1_NAME} ${MASTER_2_NAME} ${MASTER_3_NAME}; do
#  rm ${instance}*csr.json
#done
