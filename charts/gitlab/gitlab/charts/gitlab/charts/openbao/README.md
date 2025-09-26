# OpenBao

[![Release](https://gitlab.com/gitlab-org/cloud-native/charts/openbao/-/badges/release.svg)](#)
[![Pipeline](https://gitlab.com/gitlab-org/cloud-native/charts/openbao/badges/main/pipeline.svg)](#)

:warning: This project is in early development stage and is not yet suitable
for production use.

Deploy OpenBao server for usage within a GitLab installation.

## Goals

This chart aims to:

1. Only support features for usage within GitLab (e.g. the PostgreSQL backend).
1. Default to HA.
1. Automate HA compliant upgrades.
1. Support automatic unsealing from a sidecar.
