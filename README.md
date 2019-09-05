# Kubernetes the Hard Way on Bare Metal

Hands-on learning to understand the tasks required to bootstrap a Kubernetes cluster on bare metal environment. The definition of bare metal here is referring to a few physical servers, or Virtual Machines at home or office.

This is based on [Kubernetes The Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way) and [kubeadm](https://github.com/kubernetes/kubeadm) with a few extensions.

Check [mini-k8s-the-hard-way](https://github.com/oahcran/mini-k8s-the-hard-way) for experiment, like [containerd](https://containerd.io/) container runtime.

## Cluster Details

* Kubernetes `v1.14.3`
* etcd `v3.3.13`
* cri-tools `v1.14.0`
* CNI `v0.7.5`
* Flannel `v0.11.0`
* docker-ce `18.06.3~ce~3-0~ubuntu`
* CoreDNS `v1.5.0`
* Ubuntu `16.04.6 LTS`
* MetalLB `v0.7.3`
* Nginx `1.14.0`
* metrics-server `v0.3.3` (Miscellaneous)

## Steps

* [Preparing Network and Compute Resources](docs/01-preparing-resources.md)
* [Provisioning the CA and Generating TLS Certificates, Configuration Files and Data Encryption Config](docs/02-provisioning-certs-config-encryption.md)
* [Bootstrapping the etcd Cluster](docs/03-bootstrapping-etcd.md)
* [Bootstrapping the Control Plane](docs/04-bootstrapping-kubernetes-controllers.md)
* [Bootstrapping the Worker Nodes](docs/05-bootstrapping-kubernetes-workers.md)
* [Deploying CNI Networking Plugin](docs/06-deploying-cni-network-plugin.md)
* [Deploying the DNS Cluster Add-on](docs/07-dns-addon.md)
* [Deploying the MetalLB](docs/08-deploying-the-metallb.md)
* [Miscellaneous](docs/09-miscellaneous.md)

## Change Log

* [Change Log](docs/change-log.md)
