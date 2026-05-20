# AGENTS.md

This file provides guidance to AI coding assistants when working with this repository.

## Overview

The GitLab Helm chart (`gitlab/gitlab`) deploys all GitLab foundational components on Kubernetes. It composes sub-charts for GitLab services and bundles external dependencies (cert-manager, Prometheus, Gateway API — see `Chart.yaml` for the authoritative full list).

## Commands

```bash
bundle install                              # Install Ruby test dependencies
bundle exec rspec                           # Run all chart tests
bundle exec rspec spec/path/to_spec.rb      # Run single spec
bundle exec rubocop                         # Lint Ruby code

helm dependency update                      # Fetch/update chart dependencies
helm lint .                                 # Lint the chart
helm template . -f values.yaml              # Render templates locally
```

## Architecture

### Chart Structure

- `Chart.yaml` — chart metadata; lists bundled dependencies (cert-manager, Prometheus, Gateway API — see `Chart.yaml` for pinned versions and the authoritative full list)
- `charts/` — GitLab sub-charts, one per service component
- `templates/` — top-level shared templates (RBAC, secrets, etc.)
- `values.yaml` — default configuration values
- `examples/` — reference configs for different deployment sizes

### GitLab Sub-charts (`charts/`)

Each GitLab service is its own sub-chart:

- `gitlab` - Parent chart for core GitLab components
- `gitlab/webservice/` — Rails web workers (Puma+Workhorse)
- `gitlab/sidekiq/` — background job workers
- `gitlab/gitaly/` — Git RPC service
- `gitlab/gitlab-shell/` — SSH access
- `gitlab/kas/` — Kubernetes Agent Server
- `gitlab/toolbox/` — backup/restore toolbox pod
- `gitlab/migrations/` — database migration jobs
- `registry/` — Container registry
- `gitlab-runner/` — optional bundled runner

### Cloud Native GitLab (CNG) containers

This Helm chart consumes a number of containers from `registry.gitlab.com/gitlab-org/build/cng/*`.
Those containers originate from `gitlab.com/gitlab-org/build/CNG`, and their sources can be found there.

### External Dependencies (bundled)

- **cert-manager** — `jetstack/cert-manager`
- **Prometheus** — `prometheus-community/prometheus`
- **Envoy Gateway** - Gateway API implementation - `gateway-helm`
- **PostgreSQL**, **Redis** and **MinIO** - still bundled optionally (`bitnami/postgresql`, `bitnami/redis`, `MinIO`) for proof of concept and testing environments. Will be removed in 19.0.
- **Ingress controllers**: NGINX Ingress, Traefik Ingress, and HAProxy Ingress are deprecated but still bundled as optional dependencies. They are announced to be removed in 20.0.

### Key Design Decisions

- Object storage (S3-compatible) is required for shared data
- Components are designed to run without root privileges, though some cluster configurations may require adjustments
- All inter-service communication uses Kubernetes Services
- Secrets managed via Kubernetes Secret objects
- Horizontal scaling via standard Kubernetes HPA

### Configuration Hierarchy

`global` values in `values.yaml` propagate to all sub-charts. Each sub-chart can override at its own level. The `gitlab.yml.erb` template in each service's ConfigMap is generated from Helm values.

**Convention**: Be intentional about what goes under `global`. Values tightly bound to a single sub-chart should live at the sub-chart level, not global. The chart has existing values in `global` for historical/consistency reasons (e.g. `global.gatewayApi`) that are being progressively relocated.

See the [development docs](doc/development/_index.md) for architecture details, style guide, and contribution guidelines.

### Examples Directory

There is an `examples/` directory. It contains a mix of Helm values files and other snippets.
For consistency, nearly all example values are named with a `values-` prefix.
This is not always the case, and not all YAML in this directory is Helm values.
For all future additions, please suggest helm values files be prefixed with `values-`, and resources be named
clearly according to their contents.

## CI Pipeline

`.gitlab-ci.yml` stages: `test → preflight → staging → review`

Uses Knapsack for parallel RSpec test distribution across CI nodes.

This project makes use of Ruby and RSpec for extensive and adaptable rendered template testing via `helm template`.
We also secondarily parse ERB and `gomplate`, after extracting from `helm template`.
RSpec behavioral guidance can be found in `doc/development/rspec.md`.

## Merge Requests

When creating MRs for this repo, always use the appropriate MR template from `.gitlab/merge_request_templates/`:

- **`Default.md`** — for all code changes (features, bug fixes, refactors, tooling)
- **`Documentation.md`** — for documentation-only changes (branch name must start with `docs-`/`docs/` or end with `-docs`)

The templates include required author/reviewer checklists and quick actions that apply labels and assignment. Always populate the template fully rather than replacing it with a custom description.

Additionally, never push anything to remote without asking for approval, unless you were directly told to do that.

## Documentation

Nearly all documentation lives under `doc/`.
This is linted in several ways: Vale and markdownlint.
See `.vale.ini` for Vale configuration.
See `.markdownlint-cli2.yaml` for markdownlint configuration.

## Development Environment

This repository makes use of mise tooling, configured via `mise.toml`.

We regularly develop with several tools:
- [colima](https://colima.run/docs/)
- [Rancher Desktop](https://docs.rancherdesktop.io/)
- [kind](https://kind.sigs.k8s.io/)

Further documentation is present in `doc/development/environment_setup.md`.
