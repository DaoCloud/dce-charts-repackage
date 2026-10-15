# LWS

Repackages `oci://registry.k8s.io/lws/charts/lws` as a parent chart with
three-part image values for offline relocation and DaoCloud mirror defaults.
Upstream settings are available under `lws` in the parent values.

LWS 0.8.0 requires Kubernetes >= 1.26. On Kubernetes 1.26, enable
`StatefulSetStartOrdinal`. Parallel rolling updates also require
`MaxUnavailableStatefulSet`; otherwise Pods roll out one by one.
See <https://github.com/kubernetes-sigs/lws/blob/v0.8.0/site/content/en/docs/installation/_index.md>.

```bash
make build_chart PROJECT=lws
make e2e PROJECT=lws
```

Helm installs the bundled CRDs on initial installation. For upgrades, apply
`lws/charts/lws/crds` with server-side apply before upgrading the release.
