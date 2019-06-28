# Deploying CNI Networking Plugin

## The Flannel Pod Network Add-on

Deploy the `flannel` networking add-on:

```
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.11.0/Documentation/kube-flannel.yml
```

Use the one below as above yml still use flannel `v0.10.0`

```
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/a70459be0084506e4ec919aa1c114638878db11b/Documentation/kube-flannel.yml
```

> output

```
clusterrole.rbac.authorization.k8s.io/flannel created
clusterrolebinding.rbac.authorization.k8s.io/flannel created
serviceaccount/flannel created
configmap/kube-flannel-cfg created
daemonset.extensions/kube-flannel-ds-amd64 created
daemonset.extensions/kube-flannel-ds-arm64 created
daemonset.extensions/kube-flannel-ds-arm created
daemonset.extensions/kube-flannel-ds-ppc64le created
daemonset.extensions/kube-flannel-ds-s390x created
```

List the pods created by the `kube-flannel` [DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/):

```
kubectl get pod,ds -l app=flannel -n kube-system
```

> output

```
NAME                              READY   STATUS    RESTARTS   AGE
pod/kube-flannel-ds-amd64-bddrm   1/1     Running   0          12m
pod/kube-flannel-ds-amd64-pqgvl   1/1     Running   0          12m
pod/kube-flannel-ds-amd64-zgtbj   1/1     Running   0          12m

NAME                                           DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR                     AGE
daemonset.extensions/kube-flannel-ds-amd64     3         3         3       3            3           beta.kubernetes.io/arch=amd64     12m
daemonset.extensions/kube-flannel-ds-arm       0         0         0       0            0           beta.kubernetes.io/arch=arm       12m
daemonset.extensions/kube-flannel-ds-arm64     0         0         0       0            0           beta.kubernetes.io/arch=arm64     12m
daemonset.extensions/kube-flannel-ds-ppc64le   0         0         0       0            0           beta.kubernetes.io/arch=ppc64le   12m
daemonset.extensions/kube-flannel-ds-s390x     0         0         0       0            0           beta.kubernetes.io/arch=s390x     12m
```

### Note

On `Ubuntu 16.04`, the `/run/systemd/resolve` folder doesn't exist. Creating `kube-flannel` pod fail with error message `Failed create pod sandbox: open /run/systemd/resolve/resolv.conf: no such file or directory`.

Solution is to link `/run/systemd/resolve` with `/run/resolvconf/`

```
sudo ln -s /run/resolvconf/ /run/systemd/resolve
```

[kubernetes/kubeadm#1124](https://github.com/kubernetes/kubeadm/issues/1124)

### Verification

Check Worker nodes status:

```
kubectl get nodes
```

> output

```
NAME           STATUS   ROLES    AGE   VERSION
k8s-worker-1   Ready    <none>   39m   v1.14.3
k8s-worker-2   Ready    <none>   33m   v1.14.3
k8s-worker-3   Ready    <none>   27m   v1.14.3
```

Check Worker nodes conditions `kubectl describe node k8s-worker-1` to verify kubelet ready:

```
...
KubeletReady                 kubelet is posting ready status. AppArmor enabled
...
```

Prev: [Bootstrapping the Worker Nodes](05-bootstrapping-kubernetes-workers.md)

Next: [Deploying the DNS Cluster Add-on](07-dns-addon.md)
