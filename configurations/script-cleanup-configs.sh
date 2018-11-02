#!/bin/bash
set -e

export WOKRER_NODE_1_NAME=k8s-worker-1
export WOKRER_NODE_2_NAME=k8s-worker-2
export WOKRER_NODE_3_NAME=k8s-worker-3

rm *.csr *.pem *.kubeconfig

rm encryption-config.yaml

for instance in ${WOKRER_NODE_1_NAME} ${WOKRER_NODE_2_NAME} ${WOKRER_NODE_3_NAME}; do
  rm ${instance}*csr.json
done

rm ./aggregator/*.csr
rm ./aggregator/*.pem
