#!/bin/bash

CHART_DIRECTORY=$1
[ ! -d "$CHART_DIRECTORY" ] && echo "custom shell: error, miss CHART_DIRECTORY $CHART_DIRECTORY " && exit 1

cd $CHART_DIRECTORY
echo "custom shell: CHART_DIRECTORY $CHART_DIRECTORY"
echo "CHART_DIRECTORY $(ls)"

#========================= add your customize bellow ====================
#===============================

set -o errexit
set -o pipefail
set -o nounset


yq -i ' .core.registry = "docker.m.daocloud.io" ' values.yaml
yq -i ' .core.manager.env.ssl=false' values.yaml
yq -i ' .core.controller.replicas=1' values.yaml
yq -i ' .core.cve.scanner.replicas=1' values.yaml
yq -i ' .core.containerd.enabled=true' values.yaml
yq -i ' .core.controller.pvc.enabled=true' values.yaml
yq -i ' .core.controller.federation.mastersvc.type = "NodePort" ' values.yaml
yq -i ' .core.controller.federation.managedsvc.type = "NodePort" ' values.yaml
yq -i ' .core.cve.updater.enabled=false ' values.yaml


yq -i ' .core.controller.resources.limits.cpu = "400m" ' values.yaml
yq -i ' .core.controller.resources.limits.memory = "2792Mi" ' values.yaml
yq -i ' .core.controller.resources.requests.cpu = "100m" ' values.yaml
yq -i ' .core.controller.resources.requests.memory = "2280Mi" ' values.yaml

yq -i ' .core.enforcer.resources.limits.cpu = "400m" ' values.yaml
yq -i ' .core.enforcer.resources.limits.memory = "2792Mi" ' values.yaml
yq -i ' .core.enforcer.resources.requests.cpu = "100m" ' values.yaml
yq -i ' .core.enforcer.resources.requests.memory = "2280Mi" ' values.yaml

yq -i ' .core.manager.resources.limits.cpu = "400m" ' values.yaml
yq -i ' .core.manager.resources.limits.memory = "2792Mi" ' values.yaml
yq -i ' .core.manager.resources.requests.cpu = "100m" ' values.yaml
yq -i ' .core.manager.resources.requests.memory = "2280Mi" ' values.yaml

yq -i ' .core.cve.scanner.resources.limits.cpu = "400m" ' values.yaml
yq -i ' .core.cve.scanner.resources.limits.memory = "2792Mi" ' values.yaml
yq -i ' .core.cve.scanner.resources.requests.cpu = "100m" ' values.yaml
yq -i ' .core.cve.scanner.resources.requests.memory = "2280Mi" ' values.yaml

yq -i ' .core.cve.resources.limits.cpu = "400m" ' values.yaml
yq -i ' .core.cve.resources.limits.memory = "2792Mi" ' values.yaml
yq -i ' .core.cve.resources.requests.cpu = "100m" ' values.yaml
yq -i ' .core.cve.resources.requests.memory = "2280Mi" ' values.yaml


echo "keywords:" >> Chart.yaml
echo "  - monitoring" >> Chart.yaml
echo "  - security" >> Chart.yaml
echo "  - networking" >> Chart.yaml
yq -i ' .name = "neuvector" ' Chart.yaml


ls
rm -f values.yaml-E || true
rm -f values.yamlE || true

exit 0
