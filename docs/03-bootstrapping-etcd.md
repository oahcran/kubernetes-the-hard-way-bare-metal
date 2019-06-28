# Bootstrapping the etcd Cluster

## Bootstrapping an etcd Cluster Member

Download the official etcd release binaries from the [coreos/etcd](https://github.com/coreos/etcd) GitHub project:

```
wget -q --show-progress --https-only --timestamping \
  "https://github.com/etcd-io/etcd/releases/download/v3.3.13/etcd-v3.3.13-linux-amd64.tar.gz"
```

Extract and install the `etcd` server and the `etcdctl` command line utility:

```
{
  tar -xvf etcd-v3.3.13-linux-amd64.tar.gz
  sudo mv etcd-v3.3.13-linux-amd64/etcd* /usr/local/bin/
}
```

### Configure the etcd Server

```
{
  sudo mkdir -p /etc/etcd /var/lib/etcd
  sudo cp ca.pem kubernetes-key.pem kubernetes.pem /etc/etcd/
}
```

The instance internal IP address will be used to serve client requests and communicate with etcd cluster peers.

```
INTERNAL_IP=$(ip addr show ens160 | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/')
```

Each etcd member must have a unique name within an etcd cluster. Set the etcd name to match the hostname of the current compute instance:

```
ETCD_NAME=$(hostname -s)
```

Create the `etcd.service` systemd unit file:

```
cat <<EOF | sudo tee /etc/systemd/system/etcd.service
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
ExecStart=/usr/local/bin/etcd \\
  --name ${ETCD_NAME} \\
  --cert-file=/etc/etcd/kubernetes.pem \\
  --key-file=/etc/etcd/kubernetes-key.pem \\
  --peer-cert-file=/etc/etcd/kubernetes.pem \\
  --peer-key-file=/etc/etcd/kubernetes-key.pem \\
  --trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-client-cert-auth \\
  --client-cert-auth \\
  --initial-advertise-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-client-urls https://${INTERNAL_IP}:2379,https://127.0.0.1:2379 \\
  --advertise-client-urls https://${INTERNAL_IP}:2379 \\
  --initial-cluster-token etcd-cluster-0 \\
  --initial-cluster k8s-master-1=https://172.18.30.21:2380,k8s-master-2=https://172.18.30.22:2380,k8s-master-3=https://172.18.30.23:2380 \\
  --initial-cluster-state new \\
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

> TIP: Put right etcd cluster nodes information at `--initial-cluster` when creating `etcd.service`

### Start the etcd Server

```
{
  sudo systemctl daemon-reload
  sudo systemctl enable etcd
  sudo systemctl start etcd
}
```

> Remember to run the above commands on each Master node.

## Verification

List the etcd cluster members:

```
sudo ETCDCTL_API=3 etcdctl member list \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/ca.pem \
  --cert=/etc/etcd/kubernetes.pem \
  --key=/etc/etcd/kubernetes-key.pem
```

> output

```
a3c0fddfd50bee0, started, k8s-master-1, https://172.18.30.21:2380, https://172.18.30.21:2379
33869c19d6cfc018, started, k8s-master-3, https://172.18.30.23:2380, https://172.18.30.23:2379
c4f90a748065621d, started, k8s-master-2, https://172.18.30.22:2380, https://172.18.30.22:2379
```


Prev: [Provisioning the CA and Generating TLS Certificates, Configuration Files and Data Encryption Config](02-provisioning-certs-config-encryption.md)

Next: [Bootstrapping the Control Plane](04-bootstrapping-kubernetes-controllers.md)
