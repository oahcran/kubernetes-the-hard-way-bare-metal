# Kubernetes the Hard Way on Bare Metal

Hands-on learning to understand the tasks required to bootstrap a Kubernetes cluster on bare metal environment. The definition of bare metal here is referring to a few physical servers, or Virtual Machines at home or office.

This is based on [Kubernetes The Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way) and [kubeadm](https://github.com/kubernetes/kubeadm) with a few extensions.

## Cluster Details

* Kubernetes v1.11.4
* etcd v3.3.10
* cri-tools v1.11.1
* CNI v0.6.0
* Flannel v0.9.1
* docker-ce 18.06.1-ce
* CoreDNS v1.2.5
* Ubuntu 18.04.1 LTS
* MetalLB v0.7.3
* Nginx 1.14.0
* metrics-server v0.3.1 (Appendix)

## Steps

* [Preparing Network and Compute Resources](docs/01-preparing-resources.md)
* [Provisioning the CA and Generating TLS Certificates, Configuration Files and Data Encryption Config](docs/02-provisioning-certs-config-encryption.md)
* [Bootstrapping the etcd Cluster](docs/03-bootstrapping-etcd.md)
* [Bootstrapping the Control Plane](docs/04-bootstrapping-kubernetes-controllers.md)
* [Bootstrapping the Worker Nodes](docs/05-bootstrapping-kubernetes-workers.md)
* [Deploying CNI Networking Plugin](docs/06-deploying-cni-network-plugin.md)
* [Deploying the DNS Cluster Add-on](docs/07-dns-addon.md)
* [Deploying the MetalLB](docs/08-deploying-the-metalb.md)
* [Miscellaneous](docs/09-miscellaneous.md)
