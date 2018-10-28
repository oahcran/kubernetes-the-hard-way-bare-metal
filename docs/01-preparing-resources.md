# Preparing Network and Compute Resources

Setup a subnet for infra network and no firewall for internal/external communication, e.g. [pfSense](https://www.pfsense.org/)

|Network         |CIDR             |
|----------------|-----------------|
|Infra Network   |`172.18.30.1/24` |
|Pod Network     |`10.244.0.0/16`  |
|Service Network |`10.32.0.0/24`   |

## Infra Network for VMs

|IP Address      |VM Hostname    |
|----------------|---------------|
|172.18.30.20    |`k8s-elb`      |
|172.18.30.21    |`k8s-master-1` |
|172.18.30.22    |`k8s-master-2` |
|172.18.30.23    |`k8s-master-3` |
|172.18.30.31    |`k8s-worker-1` |
|172.18.30.32    |`k8s-worker-2` |
|172.18.30.33    |`k8s-worker-3` |

* 172.18.30.1: Gateway
* 172.18.30.0-172.19.30.10: Reserved IP Range
* 172.18.30.11-172.19.30.199: Static IP Range
* 172.18.30.200-172.18.30.254: DHCP IP Range

## Operating System

**Ubuntu 18.04.1 LTS**

Update each instance `/etc/hosts` file:

```
172.18.30.20   k8s-elb
172.18.30.21   k8s-master-1
172.18.30.22   k8s-master-2
172.18.30.23   k8s-master-3
172.18.30.31   k8s-worker-1
172.18.30.32   k8s-worker-2
172.18.30.33   k8s-worker-3
```

## Service Network

* `10.32.0.1` - API Server Service Network IP Address
* `10.32.0.10` - DNS Server IP Address for Service Discovery

Next: [Provisioning the CA and Generating TLS Certificates, Configuration Files and Data Encryption Config](02-provisioning-certs-config-encryption.md)
