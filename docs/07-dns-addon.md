# Deploying the DNS Cluster Add-on

## The DNS Cluster Add-on

Kubernetes DNS schedules a DNS Pod and Service on the cluster, and configures the kubelets to tell individual containers to use the DNS Service’s IP to resolve DNS names

- [DNS for Services and Pods](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/)
- [Specification](https://github.com/kubernetes/dns/blob/master/docs/specification.md)

The [official guidance](https://github.com/coredns/deployment/tree/master/kubernetes) provides a convenience script to generate a manifest for running CoreDNS on a cluster that is currently running standard kube-dns.

For this case to deploy from scratch, review the [coredns kubernetes repo](https://github.com/coredns/coredns/tree/master/plugin/kubernetes), [deployment repo](https://github.com/coredns/deployment/tree/master/kubernetes) and [kubernetes-the-hard-way example](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/1.12.0/docs/12-dns-addon.md)

Replace the variables with appropriate value at [template file](https://github.com/coredns/deployment/blob/master/kubernetes/coredns.yaml.sed):

```
CLUSTER_DOMAIN="cluster.local"
REVERSE_CIDRS="in-addr.arpa ip6.arpa"
UPSTREAMNAMESERVER="/etc/resolv.conf"
STUBDOMAINS=""
FEDERATIONS=""
CLUSTER_DNS_IP="10.32.0.10"
```

Deploy the add-on

```
kubectl apply -f deployments/coredns.yaml
```

> output

```
serviceaccount/coredns created
clusterrole.rbac.authorization.k8s.io/system:coredns created
clusterrolebinding.rbac.authorization.k8s.io/system:coredns created
configmap/coredns created
deployment.extensions/coredns created
service/kube-dns created
```

List the pods created by the `kube-dns` deployment:

```
kubectl get pods -l k8s-app=kube-dns -n kube-system
```

> output

```
NAME                       READY     STATUS    RESTARTS   AGE
coredns-5c64869bbf-2b6jc   1/1       Running   0          1m
coredns-5c64869bbf-ffqbd   1/1       Running   0          1m
```

### Verification

Create a `busybox` deployment:

```
kubectl run busybox --image=busybox:1.28 --command -- sleep 3600
```

List the pod created by the `busybox` deployment:

```
kubectl get pods -l run=busybox
```

> output

```
NAME                      READY   STATUS    RESTARTS   AGE
busybox-bd8fb7cbd-vflm9   1/1     Running   0          10s
```

Retrieve the full name of the `busybox` pod:

```
POD_NAME=$(kubectl get pods -l run=busybox -o jsonpath="{.items[0].metadata.name}")
```

Execute a DNS lookup for the `kubernetes` service inside the `busybox` pod:

```
kubectl exec -ti $POD_NAME -- nslookup kubernetes
```

> output

```
Server:    10.32.0.10
Address 1: 10.32.0.10 kube-dns.kube-system.svc.cluster.local

Name:      kubernetes
Address 1: 10.32.0.1 kubernetes.default.svc.cluster.local
```

Prev: [Deploying CNI Networking Plugin](06-deploying-cni-network-plugin.md)

Next: [Deploying the MetaLB](08-deploying-the-metalb.md)
