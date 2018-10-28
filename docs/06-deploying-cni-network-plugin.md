# Deploying CNI Networking Plugin

## The Flannel Pod Network Add-on

Deploy the `flannel` networking add-on:

```
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml
```

> output

```
clusterrole.rbac.authorization.k8s.io/flannel created
clusterrolebinding.rbac.authorization.k8s.io/flannel created
serviceaccount/flannel created
configmap/kube-flannel-cfg created
daemonset.extensions/kube-flannel-ds created
```

List the pods created by the `kube-flannel` [DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/):

```
kubectl get pod,ds -l app=flannel -n kube-system
```

> output

```
NAME                        READY     STATUS    RESTARTS   AGE
pod/kube-flannel-ds-7q4p4   1/1       Running   0          28s
pod/kube-flannel-ds-k7ng7   1/1       Running   0          28s
pod/kube-flannel-ds-xhn4d   1/1       Running   0          28s

NAME                                   DESIRED   CURRENT   READY     UP-TO-DATE   AVAILABLE   NODE SELECTOR                   AGE
daemonset.extensions/kube-flannel-ds   3         3         3         3            3           beta.kubernetes.io/arch=amd64   28s
```

### Verification

Check Worker nodes status:

```
kubectl get nodes
```

> output

```
NAME           STATUS    ROLES     AGE       VERSION
k8s-worker-1   Ready     <none>    1h        v1.11.4
k8s-worker-2   Ready     <none>    33m       v1.11.4
k8s-worker-3   Ready     <none>    33m       v1.11.4
```

Check Worker nodes conditions `kubectl describe node k8s-worker-1` to verify kubelet ready:

```
...
KubeletReady                 kubelet is posting ready status. AppArmor enabled
...
```

Prev: [Bootstrapping the Worker Nodes](05-bootstrapping-kubernetes-workers.md)

Next: [Deploying the DNS Cluster Add-on](07-dns-addon.md)
