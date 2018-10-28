# Miscellaneous

## Troubleshooting

* [Reading the system log](https://coreos.com/os/docs/latest/reading-the-system-log.html)

## Smoke Test

* [Kubernetes the Hard Way Smoke Test](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/13-smoke-test.md)

* [Deploy Guest Book Application](https://github.com/kubernetes/examples/tree/master/guestbook-go)

## Configuring kubectl for Remote Access

```
KUBERNETES_PUBLIC_ADDRESS=172.18.30.20

kubectl config set-cluster the-hard-way-metal \
  --certificate-authority=ca.pem \
  --embed-certs=true \
  --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443

kubectl config set-credentials admin \
  --client-certificate=admin.pem \
  --client-key=admin-key.pem

kubectl config set-context the-hard-way-metal \
  --cluster=the-hard-way-metal \
  --user=admin

kubectl config use-context the-hard-way-metal
```

## Limitation

* Metrics won't Work

  > API Server requires the connectivities to Pod and Service network while it won't be possible without additional routing changes at API Server instances. The workaround might be to allow containers running on master instances installing `kubelet` and `kubeproxy` etc., similar to worker instances setup.  [GitHub Issue](https://github.com/kubernetes-incubator/metrics-server/issues/22)


Prev: [Deploying the MetaLB](08-deploying-the-metalb.md)
