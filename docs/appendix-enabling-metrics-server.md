# Enable Metrics Server

Prerequisites:

- API Server has connectivities to Pod and Service Network. This could be done by Appendix _Add Master to Nodes Cluster_
- Enable [Aggregation Layer](https://kubernetes.io/docs/tasks/access-kubernetes-api/configure-aggregation-layer/)

## Provisioning aggregator CA and Client certificates

prepare the `aggregator-ca-config.json`, `aggregator-ca-csr.json` and `aggregator-proxy-client-csr.json`.

create CA and Proxy Client

```
cfssl gencert -initca aggregator-ca-csr.json | cfssljson -bare aggregator-ca

cfssl gencert \
  -ca=aggregator-ca.pem \
  -ca-key=aggregator-ca-key.pem \
  -config=aggregator-ca-config.json \
  -profile=aggregator \
  aggregator-proxy-client-csr.json | cfssljson -bare aggregator-proxy-client
```

## Distributing files to Master nodes

```
for instance in k8s-master-1 k8s-master-2 k8s-master-3; do
  scp aggregator-ca.pem aggregator-proxy-client-key.pem aggregator-proxy-client.pem ubuntu@${instance}:~/
done  
```

#### Update API Server configurations

```
sudo mkdir -p /var/lib/kubernetes/aggregator

sudo mv aggregator-ca.pem aggregator-proxy-client-key.pem \
    aggregator-proxy-client.pem /var/lib/kubernetes/aggregator
```

Update `kube-apiserver.service` to include Aggregation Layer

```
--requestheader-client-ca-file=/var/lib/kubernetes/aggregator/aggregator-ca.pem \\
--requestheader-allowed-names=aggregator \\
--requestheader-extra-headers-prefix=X-Remote-Extra- \\
--requestheader-group-headers=X-Remote-Group \\
--requestheader-username-headers=X-Remote-User \\
--proxy-client-cert-file=/var/lib/kubernetes/aggregator/aggregator-proxy-client.pem \\
--proxy-client-key-file=/var/lib/kubernetes/aggregator/aggregator-proxy-client-key.pem \\
```

This is the full output

```
INTERNAL_IP=$(ip addr show ens160 | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/')


cat <<EOF | sudo tee /etc/systemd/system/kube-apiserver.service
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-apiserver \\
  --advertise-address=${INTERNAL_IP} \\
  --allow-privileged=true \\
  --apiserver-count=3 \\
  --audit-log-maxage=30 \\
  --audit-log-maxbackup=3 \\
  --audit-log-maxsize=100 \\
  --audit-log-path=/var/log/audit.log \\
  --authorization-mode=Node,RBAC \\
  --bind-address=0.0.0.0 \\
  --client-ca-file=/var/lib/kubernetes/ca.pem \\
  --enable-admission-plugins=NamespaceLifecycle,NodeRestriction,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota \\
  --enable-swagger-ui=true \\
  --etcd-cafile=/var/lib/kubernetes/ca.pem \\
  --etcd-certfile=/var/lib/kubernetes/kubernetes.pem \\
  --etcd-keyfile=/var/lib/kubernetes/kubernetes-key.pem \\
  --etcd-servers=https://172.18.30.21:2379,https://172.18.30.22:2379,https://172.18.30.23:2379 \\
  --event-ttl=1h \\
  --experimental-encryption-provider-config=/var/lib/kubernetes/encryption-config.yaml \\
  --kubelet-certificate-authority=/var/lib/kubernetes/ca.pem \\
  --kubelet-client-certificate=/var/lib/kubernetes/kubernetes.pem \\
  --kubelet-client-key=/var/lib/kubernetes/kubernetes-key.pem \\
  --kubelet-https=true \\
  --runtime-config=api/all \\
  --service-account-key-file=/var/lib/kubernetes/service-account.pem \\
  --service-cluster-ip-range=10.32.0.0/24 \\
  --service-node-port-range=30000-32767 \\
  --tls-cert-file=/var/lib/kubernetes/kubernetes.pem \\
  --tls-private-key-file=/var/lib/kubernetes/kubernetes-key.pem \\
  --requestheader-client-ca-file=/var/lib/kubernetes/aggregator/aggregator-ca.pem \\
  --requestheader-allowed-names=aggregator \\
  --requestheader-extra-headers-prefix=X-Remote-Extra- \\
  --requestheader-group-headers=X-Remote-Group \\
  --requestheader-username-headers=X-Remote-User \\
  --proxy-client-cert-file=/var/lib/kubernetes/aggregator/aggregator-proxy-client.pem \\
  --proxy-client-key-file=/var/lib/kubernetes/aggregator/aggregator-proxy-client-key.pem \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

## Restart API Server

```
{
  sudo systemctl daemon-reload
  sudo systemctl restart kube-apiserver
}
```

## Update `coredns`

The `metrics-server` requires the IP Addresses mapping of Cluster Nodes. Update `coredns.yaml` to enable `hosts` plugin at _CoreFile_

```
hosts k8s.hosts {
  172.18.30.21 k8s-master-1
  172.18.30.22 k8s-master-2
  172.18.30.23 k8s-master-3
  172.18.30.31 k8s-worker-1
  172.18.30.32 k8s-worker-2
  172.18.30.33 k8s-worker-3
  fallthrough
}
```

Apply the changes, by default `coredns` would reload in 15 seconds

```
kubectl apply -f deployments/coredns.yaml
```

## Install `metrics-server`

```
kubectl create -f deployments/metrics-server/
```

### Verification

```
$ kubectl top nodes

NAME           CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
k8s-master-1   127m         6%     1741Mi          45%
k8s-master-2   134m         6%     1475Mi          38%
k8s-master-3   125m         6%     1627Mi          42%
k8s-worker-1   78m          3%     794Mi           20%
k8s-worker-2   100m         5%     774Mi           20%
k8s-worker-3   78m          3%     831Mi           21%
```
