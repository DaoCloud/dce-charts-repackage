## Overview

cert-manager is a Kubernetes addon to automate the management and issuance of TLS certificates from various issuing sources.  
It will ensure certificates are valid and up to date periodically, and attempt to renew certificates at an appropriate time before expiry.

## Prerequisites

* Kubernetes 1.18+

## Install

```shell
helm repo add daocloud-system https://release.daocloud.io/chartrepo/system
helm install cert-manager daocloud-system/cert-manager
helm ls
```
