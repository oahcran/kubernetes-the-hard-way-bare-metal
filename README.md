# Kubernetes the Hard Way on Bare Metal

This tutorial is intended for learning to understand the tasks required to bootstrap a Kubernetes cluster on bare metal environment. The definition of bare metal here is referring to a few physical servers, or Virtual Machines at home or office. 

This is based on Kelsey Hightower's [Kubernetes The Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way) and [kubeadm](https://github.com/kubernetes/kubeadm). 

## Cluster Details

* Kubernetes v1.11.3
* etcd v3.3.9
* cri-tools v1.11.1
* CNI v0.6.0
* CoreDNS v1.2.2
* Flannel v0.9.1
* docker-ce 18.06.1-ce
* Ubuntu 18.04.1 LTS 
* MetalLB v0.7.3
* Nginx 1.14.0

## Labs

* Preparing Network and Compute Resources
* Provisioning the CA and Generating TLS Certificates
* Generating Kubernetes Configuration Files for Authentication and the Data Encryption Config and Key
* Distributing Files to Instances
* Bootstrapping the etcd Cluster
* Bootstrapping the Kubernetes Control Plane
* Bootstrapping the Kubernetes Worker Nodes
* Configuring kubectl for Remote Access
* Deploying CNI Networking Plugin
* Deploying the DNS Cluster Add-on
* Deploying the MetaLB
* Smoke Test
* Appendix