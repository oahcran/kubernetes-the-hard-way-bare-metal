#!/bin/bash
set -e

export WOKRER_NODE_1_NAME=k8s-worker-1
export WOKRER_NODE_2_NAME=k8s-worker-2
export WOKRER_NODE_3_NAME=k8s-worker-3

rm *.csr *.pem *.kubeconfig

rm ${WOKRER_NODE_1_NAME}*csr.json
rm ${WOKRER_NODE_2_NAME}*csr.json
rm ${WOKRER_NODE_3_NAME}*csr.json
rm encryption-config.yaml
