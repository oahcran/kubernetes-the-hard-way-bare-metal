# Provisioning the CA and Generating TLS Certificates

Follow the [Kubernetes The Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way) and changes made to comply to [Network/Compute Design](01-preparing-resources.md).

All the configuration file put to `configuration` folder. Run the `generate-configs.sh` to generate certificate, private key and configuration files.

## Certificate Authority

Prepare the CA configuration file `ca-config.json` and CSR file `ca-csr.json` to generate certificate and private key:

```
ca-key.pem
ca.pem
```

## Server Certificates

* The Kubernetes API Server Certificate

### The Kubernetes API Server Certificate

Prepare `kubernetes-csr.json` file to generate the Kubernetes API Server certificate and private key:

```
kubernetes-key.pem
kubernetes.pem
```

> TIP: `KUBERNETES_PUBLIC_ADDRESS` value is set to `k8s-elb` IP address acting as external load balancer in front of 3 Master VMs.

> TIP: All IP Address, FQDN and Domain representing API Server are included in the list of subject alternative names for the server cert.

## Client Certificates

* The Admin Client Certificate
* The Kubelet Client Certificates
* The Kube Proxy Client Certificate
* The Controller Manager Client Certificate
* The Scheduler Client Certificate

All the Client Authentication is to make use of [X509 Client Certs](https://kubernetes.io/docs/reference/access-authn-authz/authentication/). If a client certificate is presented and verified, the `Common Name` (`CN`) of the subject is used as the user name and the `Organization` (`O`) is used as user's group.

### The Admin Client Certificate

Prepare `admin-csr.json` file to generate the `admin` client certificate and private key:

```
admin-key.pem
admin.pem
```

### The Kubelet Client Certificates

Kubernetes uses a [special-purpose authorization mode](https://kubernetes.io/docs/admin/authorization/node/) called `Node Authorizer`, that specifically authorizes API requests made by [Kubelets](https://kubernetes.io/docs/concepts/overview/components/#kubelet). In order to be authorized by the Node Authorizer, Kubelets must use a credential that identifies them as being in the `system:nodes` group, with a username of `system:node:<nodeName>`. In this section you will create a certificate for each Kubernetes worker node that meets the Node Authorizer requirements.

Prepare `${instance}-csr.json` to generate a certificate and private key for each Kubernetes worker node:

```
k8s-worker-1-key.pem
k8s-worker-1.pem
k8s-worker-2-key.pem
k8s-worker-2.pem
k8s-worker-3-key.pem
k8s-worker-3.pem
```

### The Kube Proxy Client Certificate

Prepare `kube-proxy-csr.json` to generate the `kube-proxy` client certificate and private key:

```
kube-proxy-key.pem
kube-proxy.pem
```

###  The Controller Manager Client Certificate

Prepare `kube-controller-manager-csr.json` to generate the `kube-controller-manager` client certificate and private key:

```
kube-controller-manager-key.pem
kube-controller-manager.pem
```

### The Scheduler Client Certificate

Prepare `kube-scheduler-csr.json` to generate the `kube-scheduler` client certificate and private key:

```
kube-scheduler-key.pem
kube-scheduler.pem
```

## The Service Account Key Pair

From [Managing Service Accounts](https://kubernetes.io/docs/reference/access-authn-authz/service-accounts-admin/):

> You must pass a service account private key file to the token controller in the controller-manager by using the `--service-account-private-key-file` option. The private key will be used to sign generated service account tokens. Similarly, you must pass the corresponding public key to the kube-apiserver using the `--service-account-key-file` option. The public key will be used to verify the tokens during authentication.

The `ServiceAccount` Admission Controller need to be enabled when configuring `API Server`.

Prepare `service-account-csr.json` to generate the `service-account` certificate and private key:

```
service-account-key.pem
service-account.pem
```

# Generating Kubernetes Configuration Files for Authentication

## Client Authentication Configs

Generate [Kubernetes configuration files](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/), also known as kubeconfigs, which enable Kubernetes clients to locate and authenticate to the Kubernetes API Servers.

> TIP: `KUBERNETES_PUBLIC_ADDRESS` value is set to `k8s-elb` IP address acting as external load balancer in front of 3 Master VMs.

> The `kubeconfig` includes `ca.pem`, the client certificate and private key (for example, kube-proxy.kubeconfig contains `kube-proxy.pem`, `kube-proxy-key.pem`)

* The `kubelet` Kubernetes Configuration File

  When generating kubeconfig files for Kubelets the client certificate matching the Kubelet's node name must be used. This will ensure Kubelets are properly authorized by the Kubernetes [Node Authorizer](https://kubernetes.io/docs/admin/authorization/node/).

  > TIP: `--authorization-mode=Node`

  ```
  k8s-worker-1.kubeconfig
  k8s-worker-2.kubeconfig
  k8s-worker-3.kubeconfig
  ```

* The `kube-proxy` Kubernetes Configuration File

  ```
  kube-proxy.kubeconfig
  ```

* The `kube-controller-manager` Kubernetes Configuration File

  ```
  kube-controller-manager.kubeconfig
  ```

* The `kube-scheduler` Kubernetes Configuration File

  ```
  kube-scheduler.kubeconfig
  ```

* The `admin` Kubernetes Configuration File

  ```
  admin.kubeconfig
  ```

# Data Encryption Config and Key

[Encrypting Secret Data at Rest](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/):

```
encryption-config.yaml
```

# Distributing Files

This is the summary for files generated and where should be distributed to, either Master or Worker instances.

**Master instance:**

```
ca.pem
ca-key.pem
kubernetes-key.pem
kubernetes.pem
service-account-key.pem
service-account.pem
admin.kubeconfig
kube-controller-manager.kubeconfig
kube-scheduler.kubeconfig
encryption-config.yaml
```

**Worker instance:**

```
ca.pem
${instance}-key.pem
${instance}.pem
${instance}.kubeconfig
kube-proxy.kubeconfig
```

Copy the appropriate files to each Worker instance:

```
for instance in k8s-worker-1 k8s-worker-2 k8s-worker-3; do
  scp ca.pem ${instance}-key.pem ${instance}.pem \
      ${instance}.kubeconfig kube-proxy.kubeconfig ubuntu@${instance}:~/
done
```

Copy the appropriate files to each Master instance:

```
for instance in k8s-master-1 k8s-master-2 k8s-master-3; do
  scp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem \
    service-account-key.pem service-account.pem \
    admin.kubeconfig kube-controller-manager.kubeconfig kube-scheduler.kubeconfig \
    encryption-config.yaml ubuntu@${instance}:~/
done
```

Prev: [Preparing Network and Compute Resources](01-preparing-resources.md)

Next: [Bootstrapping the etcd Cluster](03-bootstrapping-etcd.md)
