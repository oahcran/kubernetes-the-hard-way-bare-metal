# Change Log

changes need attention

## v1.14.3

* `Initializers` removed from `enable-admission-plugins` on Kubernetes `v1.14`

* use apiVersion `kubescheduler.config.k8s.io/v1alpha1` instead of `componentconfig/v1alpha1` at `kube-scheduler` configuration file that is changed from [`v1.13`](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.13.md#urgent-upgrade-notes). [Github Issue](https://github.com/kubernetes/kubernetes/issues/66874)

* update apiVersion to `rbac.authorization.k8s.io/v1` for `kube-apiserver` user access to the `kubelet` API

## v1.11.4

first version