# Deploying the MetalLB

[MetalLB](https://metallb.universe.tf/) is a load-balancer implementation for bare metal Kubernetes clusters, using standard routing protocols.

This tutorial uses MetalLB in Layer 2 Mode given current Network Design all instances are under same CIDR managed by [pfSense](https://www.pfsense.org/)

## Installation

Apply the manifest:

```
kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.7.3/manifests/metallb.yaml
```

> Output

```
namespace/metallb-system created
serviceaccount/controller created
serviceaccount/speaker created
clusterrole.rbac.authorization.k8s.io/metallb-system:controller created
clusterrole.rbac.authorization.k8s.io/metallb-system:speaker created
role.rbac.authorization.k8s.io/config-watcher created
clusterrolebinding.rbac.authorization.k8s.io/metallb-system:controller created
clusterrolebinding.rbac.authorization.k8s.io/metallb-system:speaker created
rolebinding.rbac.authorization.k8s.io/config-watcher created
daemonset.apps/speaker created
deployment.apps/controller created
```

Generate Layer 2 Configuration:

```
cat <<EOF | tee metallb-layer2-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 172.18.30.100-172.18.30.110
EOF
```

Apply the layer2 config yaml:

```
kubectl apply -f metallb-layer2-config.yaml
```

### Verification

Check MetaLB Pods status:

```
kubectl get pods -n metallb-system
```

> Output

```
NAME                        READY     STATUS    RESTARTS   AGE
controller-9c57dbd4-rt9st   1/1       Running   0          2m
speaker-2ph9n               1/1       Running   0          2m
speaker-4vxg8               1/1       Running   0          2m
speaker-dstn9               1/1       Running   0          2m
```

Run nginx and expose service of LoadBalancer type:

```
kubectl run nginx --image=nginx
kubectl expose deployment nginx --type=LoadBalancer --port=80
```

Check `External-IP` value:

```
kubectl get svc
```

> Output

```
NAME         TYPE           CLUSTER-IP   EXTERNAL-IP     PORT(S)        AGE
kubernetes   ClusterIP      10.32.0.1    <none>          443/TCP        4h
nginx        LoadBalancer   10.32.0.7    172.18.30.100   80:31676/TCP   6s
```

Run `curl 172.18.30.100:80` to get nginx welcome page:

```
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
...
```

Prev: [Deploying the DNS Cluster Add-on](07-dns-addon.md)

Next: [Miscellaneous](09-miscellaneous.md)
