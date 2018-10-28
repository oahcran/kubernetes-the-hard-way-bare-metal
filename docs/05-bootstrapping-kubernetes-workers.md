# Bootstrapping the Kubernetes Worker Nodes

## Provisioning a Kubernetes Worker Node

Kubernetes has enabled the use of CRI (Container Runtime Interface), a plugin interface which enables `kubelet` to use a wide variety of container runtimes. This tutorial choose the widely known container runtime `Docker`

### Download and Install Docker

Set up the repository:

```
{
  sudo apt-get update
  sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

  sudo add-apt-repository \
     "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
     $(lsb_release -cs) \
     stable"  
}
```

Install docker-ce

```
## Install docker.
apt-get update && apt-get install docker-ce=18.06.1~ce~3-0~ubuntu

# Setup daemon.
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

mkdir -p /etc/systemd/system/docker.service.d
```

Start the Docker Service

```
{
  systemctl daemon-reload
  systemctl restart docker
}
```

### Download and Install Worker Binaries

Install the OS dependencies:

```
{
  sudo apt-get update
  sudo apt-get -y install socat conntrack ipset
}
```

> The socat binary enables support for the `kubectl port-forward` command.

```
wget -q --show-progress --https-only --timestamping \
  https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.11.1/crictl-v1.11.1-linux-amd64.tar.gz \
  https://github.com/containernetworking/plugins/releases/download/v0.6.0/cni-plugins-amd64-v0.6.0.tgz \
  https://storage.googleapis.com/kubernetes-release/release/v1.11.4/bin/linux/amd64/kubectl \
  https://storage.googleapis.com/kubernetes-release/release/v1.11.4/bin/linux/amd64/kube-proxy \
  https://storage.googleapis.com/kubernetes-release/release/v1.11.4/bin/linux/amd64/kubelet
```

Create the installation directories:

```
sudo mkdir -p \
  /etc/cni/net.d \
  /opt/cni/bin \
  /var/lib/kubelet \
  /var/lib/kube-proxy \
  /var/lib/kubernetes \
  /var/run/kubernetes \
  /etc/kubernetes/manifests
```

> `/etc/kubernetes/manifests` is added to specify the location of Static Pod manifest.

Install the worker binaries:

```
{
  chmod +x kubectl kube-proxy kubelet
  sudo mv kubectl kube-proxy kubelet /usr/local/bin/
  tar -xvf crictl-v1.11.1-linux-amd64.tar.gz
  sudo mv crictl /usr/local/bin/
  sudo tar -xvf cni-plugins-amd64-v0.6.0.tgz -C /opt/cni/bin/
  sudo chown root:root /usr/local/bin/crictl
}
```

### Configure the Kubelet

```
{
  sudo mv ${HOSTNAME}-key.pem ${HOSTNAME}.pem /var/lib/kubelet/
  sudo mv ${HOSTNAME}.kubeconfig /var/lib/kubelet/kubeconfig
  sudo mv ca.pem /var/lib/kubernetes/
}
```

Create the `kubelet-config.yaml` configuration file:

```
cat <<EOF | sudo tee /var/lib/kubelet/kubelet-config.yaml
kind: KubeletConfiguration
address: 0.0.0.0
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: "/var/lib/kubernetes/ca.pem"
authorization:
  mode: Webhook
cgroupDriver: systemd
cgroupsPerQOS: true
clusterDNS:
  - "10.32.0.10"
podCIDR: "10.244.0.0/16"
clusterDomain: "cluster.local"
resolvConf: "/run/systemd/resolve/resolv.conf"
rotateCertificates: true
tlsCertFile: "/var/lib/kubelet/${HOSTNAME}.pem"
tlsPrivateKeyFile: "/var/lib/kubelet/${HOSTNAME}-key.pem"
contentType: application/vnd.kubernetes.protobuf
cpuCFSQuota: true
enableControllerAttachDetach: true
enableDebuggingHandlers: true
enforceNodeAllocatable:
  - "pods"
failSwapOn: false
hairpinMode: promiscuous-bridge
healthzBindAddress: 127.0.0.1
healthzPort: 10248
port: 10250
serializeImagePulls: true
staticPodPath: /etc/kubernetes/manifests
EOF
```

> Reference: [KubeletConfiguration contains the configuration for the Kubelet](https://github.com/kubernetes/kubernetes/blob/master/pkg/kubelet/apis/config/types.go)

> The `resolvConf` configuration is used to avoid loops when using CoreDNS for service discovery on systems running `systemd-resolved`.

Create the `kubelet.service` systemd unit file:

```
cat <<EOF | sudo tee /etc/systemd/system/kubelet.service
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=docker.service
Requires=docker.service

[Service]
ExecStart=/usr/local/bin/kubelet \\
  --config=/var/lib/kubelet/kubelet-config.yaml \\
  --pod-cidr="10.244.0.0/16" \\
  --cni-bin-dir=/opt/cni/bin \\
  --cni-conf-dir=/etc/cni/net.d \\
  --image-pull-progress-deadline=2m \\
  --kubeconfig=/var/lib/kubelet/kubeconfig \\
  --network-plugin=cni \\
  --register-node=true \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

### Configure the Kubernetes Proxy

```
sudo mv kube-proxy.kubeconfig /var/lib/kube-proxy/kubeconfig
```

Create the `kube-proxy-config.yaml` configuration file:

```
cat <<EOF | sudo tee /var/lib/kube-proxy/kube-proxy-config.yaml
kind: KubeProxyConfiguration
apiVersion: kubeproxy.config.k8s.io/v1alpha1
bindAddress: 0.0.0.0
clientConnection:
  acceptContentTypes: ""
  contentType: application/vnd.kubernetes.protobuf
  kubeconfig: "/var/lib/kube-proxy/kubeconfig"
clusterCIDR: 10.244.0.0/16
mode: "iptables"
metricsBindAddress: 127.0.0.1:10249
EOF
```

> Reference: [KubeProxyConntrackConfiguration contains conntrack settings for the Kubernetes proxy server](https://github.com/kubernetes/kubernetes/blob/master/pkg/proxy/apis/config/types.go)

Create the `kube-proxy.service` systemd unit file:

```
cat <<EOF | sudo tee /etc/systemd/system/kube-proxy.service
[Unit]
Description=Kubernetes Kube Proxy
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-proxy \\
  --config=/var/lib/kube-proxy/kube-proxy-config.yaml
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

### Start the Worker Services

```
{
  sudo systemctl daemon-reload
  sudo systemctl enable kubelet kube-proxy
  sudo systemctl start kubelet kube-proxy
}
```

> Remember to run the above commands on each worker node: `k8s-worker-1`, `k8s-worker-2`, and `k8s-worker-3`.

## Verification

Check Worker nodes status:

```
kubectl get nodes
```

> output

```
NAME           STATUS     ROLES     AGE       VERSION
k8s-worker-1   NotReady   <none>    32m       v1.11.4
k8s-worker-2   NotReady   <none>    51s       v1.11.4
k8s-worker-3   NotReady   <none>    48s       v1.11.4
```

The Worker nodes are `NotReady`, run `kubectl describe node k8s-worker-1` to find _network plugin is not ready_:

```
runtime network not ready: NetworkReady=false reason:NetworkPluginNotReady message:docker: network plugin is not ready: cni config uninitialized
```

That is expected behavior and go to next step to deploy CNI network plugin.

Prev: [Bootstrapping the Control Plane](04-bootstrapping-kubernetes-controllers.md)

Next: [Deploying CNI Networking Plugin](06-deploying-cni-network-plugin.md)
