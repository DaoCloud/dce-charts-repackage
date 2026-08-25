#! /bin/bash
CHART_DIRECTORY=$1
[ ! -d "$CHART_DIRECTORY" ] && echo "custom shell: error, miss CHART_DIRECTORY $CHART_DIRECTORY " && exit 1

cd $CHART_DIRECTORY
echo "custom shell: CHART_DIRECTORY $CHART_DIRECTORY"
echo "CHART_DIRECTORY $(ls)"

#========================= add your customize bellow ====================
#===============================

set -x
set -o errexit
set -o nounset
set -o pipefail

os=$(uname)
echo $os

echo "custom.sh"

script_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
bash ${script_path}/custom-sub.sh $@

# 适配新 chart 结构：直接更新 .hami 下的字段
# 1) 资源名改为 vgpu
yq -i '.hami.resourceName="nvidia.com/vgpu"' values.yaml


# 2) kube-scheduler 镜像仓库/仓库名/标签
yq -i '
  .hami.scheduler.kubeScheduler.image.registry = "k8s-gcr.m.daocloud.io" |
  .hami.scheduler.kubeScheduler.image.repository = "kubernetes/kube-scheduler"
' values.yaml

# 3) extender 镜像 registry 调整（仓库名保持为 projecthami/hami）
yq -i '.hami.scheduler.extender.image.registry = "docker.m.daocloud.io"' values.yaml


# 4) devicePlugin 与 monitor 镜像 registry 调整
yq -i '
  .hami.devicePlugin.image.registry = "docker.m.daocloud.io" |
  .hami.devicePlugin.monitor.image.registry = "docker.m.daocloud.io"
' values.yaml

# 5) webhook patch 镜像切换到镜像代理
yq -i '
  .hami.scheduler.patch.image.registry = "docker.m.daocloud.io" |
  .hami.scheduler.patch.image.repository = "jettech/kube-webhook-certgen" |
  .hami.scheduler.patch.image.tag = "v1.5.2"
' values.yaml

# 6) webhook patch 备用镜像（imageNew）
yq -i '
  .hami.scheduler.patch.imageNew.registry = "docker.m.daocloud.io" |
  .hami.scheduler.patch.imageNew.repository = "liangjw/kube-webhook-certgen" |
  .hami.scheduler.patch.imageNew.tag = "v1.1.1"
' values.yaml

# add device-cores-scaling config key
# line=$(sed -n -e '/deviceMemoryScaling: 1/=' values.yaml  | head -n 1)
# if [ $os == "Darwin" ];then
#     sed -i "" "$((line)) i\\
#     deviceCoresScaling: 1.0
#     " values.yaml
# elif [ $os == "Linux" ];then
#     sed -i "$((line)) i\\
#     deviceCoresScaling: 1.0
#     " values.yaml
# fi

# add device-cores-scaling config key to daemonsetnvidia.yaml
# line=$(sed -n -e '/--device-memory-scaling={{ .Values.devicePlugin.deviceMemoryScaling }}/=' charts/vgpu/templates/device-plugin/daemonsetnvidia.yaml  | head -n 1)
# if [ $os == "Darwin" ];then
#     sed -i "" "$((line)) i\\
#             - --device-cores-scaling={{ .Values.devicePlugin.deviceCoresScaling }}
#     " charts/vgpu/templates/device-plugin/daemonsetnvidia.yaml
# elif [ $os == "Linux" ];then
#     sed -i "$((line)) i\\
#             - --device-cores-scaling={{ .Values.devicePlugin.deviceCoresScaling }}
#     " charts/vgpu/templates/device-plugin/daemonsetnvidia.yaml
# fi

# cp README.md
script_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cp ${script_path}/parent/README.md .
cp ${script_path}/parent/values.schema.json .



# update chart name hami to nvidia-vgpu
if [ $os == "Darwin" ];then
    sed -i "" "s/name: hami/name: nvidia-vgpu/g" Chart.yaml
    sed -i "" "s/- name: nvidia-vgpu/- name: hami/g" Chart.yaml
    # fix sed side-effect: restore upstream dependency name hami-dra
    sed -i "" "s/name: nvidia-vgpu-dra/name: hami-dra/g" Chart.yaml
elif [ $os == "Linux" ];then
    sed -i "s/name: hami/name: nvidia-vgpu/g" Chart.yaml
    sed -i "s/- name: nvidia-vgpu/- name: hami/g" Chart.yaml
    # fix sed side-effect: restore upstream dependency name hami-dra
    sed -i "s/name: nvidia-vgpu-dra/name: hami-dra/g" Chart.yaml
fi

# hami-dra is a dependency of the child chart 'hami', not the root wrapper chart.
# Remove it from the root Chart.yaml to avoid helm package failure.
yq -i 'del(.dependencies[] | select(.name == "hami-dra"))' Chart.yaml

# update chart version
if [ $os == "Darwin" ];then
    sed -i "" "s/^version: .*$/version: ${CUSTOM_VERSION}/g" Chart.yaml
elif [ $os == "Linux" ];then
    sed -i "s/^version: .*$/version: ${CUSTOM_VERSION}/g" Chart.yaml
fi
# update nvidiaNodeSelector values
yq -i '
    .hami.devicePlugin.nvidiaNodeSelector={"nvidia.com/gpu.deploy.container-toolkit":"true", "nvidia.com/vgpu.deploy.device-plugin": "true"} |
    .hami.scheduler.nodeSelector={"nvidia.com/gpu.deploy.container-toolkit":"true"}
' values.yaml
yq -i '
    .devicePlugin.nvidiaNodeSelector={"nvidia.com/gpu.deploy.container-toolkit":"true", "nvidia.com/vgpu.deploy.device-plugin": "true"} |
    .scheduler.nodeSelector={"nvidia.com/gpu.deploy.container-toolkit":"true"}
' charts/hami/values.yaml

# add hygonImageRepository and hygonImageTag
yq e '
    .hami.devicePlugin.hygonImageRepository="4pdosc/vdcu-device-plugin" |
    .hami.devicePlugin.hygonImageTag="v1.0"
' -i values.yaml

yq e '
    .devicePlugin.hygonImageRepository="4pdosc/vdcu-device-plugin" |
    .devicePlugin.hygonImageTag="v1.0"
' -i charts/hami/values.yaml


# set icon
yq e '
    .icon="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNTAwIiBoZWlnaHQ9IjE4NDEiIHZpZXdCb3g9IjM1LjE4OCAzMS41MTIgMzUxLjQ2IDI1OC43ODUiPjx0aXRsZT5nZW5lcmF0ZWQgYnkgcHN0b2VkaXQgdmVyc2lvbjozLjQ0IGZyb20gTlZCYWRnZV8yRC5lcHM8L3RpdGxlPjxwYXRoIGQ9Ik0zODQuMTk1IDI4Mi4xMDljMCAzLjc3MS0yLjc2OSA2LjMwMi02LjA0NyA2LjMwMnYtLjAyM2MtMy4zNzEuMDIzLTYuMDg5LTIuNTA4LTYuMDg5LTYuMjc4IDAtMy43NjkgMi43MTgtNi4yOTMgNi4wODktNi4yOTMgMy4yNzktLjAwMSA2LjA0NyAyLjUyMyA2LjA0NyA2LjI5MnptMi40NTMgMGMwLTUuMTc2LTQuMDItOC4xOC04LjUtOC4xOC00LjUxMSAwLTguNTMxIDMuMDA0LTguNTMxIDguMTggMCA1LjE3MiA0LjAyMSA4LjE4OCA4LjUzMSA4LjE4OCA0LjQ4IDAgOC41LTMuMDE2IDguNS04LjE4OG0tOS45MS42OTJoLjkxbDIuMTA5IDMuNzAzaDIuMzE1bC0yLjMzNi0zLjg1OWMxLjIwNy0uMDg2IDIuMi0uNjYgMi4yLTIuMjg1IDAtMi4wMi0xLjM5My0yLjY2OC0zLjc1LTIuNjY4aC0zLjQxMXY4LjgxMmgxLjk2MWwuMDAyLTMuNzAzbTAtMS40OTJ2LTIuMTIxaDEuMzY0Yy43NDIgMCAxLjc1My4wNiAxLjc1My45NjUgMCAuOTg0LS41MjMgMS4xNTYtMS4zOTggMS4xNTZoLTEuNzE5TTMyOS40MDYgMjM3LjAyN2wxMC41OTggMjguOTkySDMxOC40OGwxMC45MjYtMjguOTkyem0tMTEuMzUtMTEuMjg5bC0yNC40MjMgNjEuODhoMTcuMjQ1bDMuODYzLTEwLjkzNWgyOC45MDNsMy42NTYgMTAuOTM1aDE4LjcyMmwtMjQuNjA1LTYxLjg4OC0yMy4zNjEuMDA4em0tNDkuMDMzIDYxLjkwM2gxNy40OTd2LTYxLjkyMmwtMTcuNS0uMDA0LjAwMyA2MS45MjZ6bS0xMjEuNDY3LTYxLjkyNmwtMTQuNTk4IDQ5LjA3OC0xMy45ODQtNDkuMDc0LTE4Ljg3OS0uMDA0IDE5Ljk3MiA2MS45MjZoMjUuMjA3bDIwLjEzMy02MS45MjZoLTE3Ljg1MXptNzAuNzI1IDEzLjQ4NGg3LjUyMWMxMC45MDkgMCAxNy45NjYgNC44OTggMTcuOTY2IDE3LjYwOSAwIDEyLjcxMy03LjA1NyAxNy42MTItMTcuOTY2IDE3LjYxMmgtNy41MjF2LTM1LjIyMXptLTE3LjM1LTEzLjQ4NHY2MS45MjZoMjguMzY1YzE1LjExMyAwIDIwLjA0OS0yLjUxMiAyNS4zODUtOC4xNDcgMy43NjktMy45NTcgNi4yMDctMTIuNjQyIDYuMjA3LTIyLjEzNCAwLTguNzA3LTIuMDYzLTE2LjQ2OS01LjY2LTIxLjMwNS02LjQ4LTguNjQ4LTE1LjgxNi0xMC4zNC0yOS43NS0xMC4zNGgtMjQuNTQ3em0tMTY1Ljc0My0uMDg2djYyLjAxMmgxNy42NDV2LTQ3LjA4NmwxMy42NzIuMDA0YzQuNTI3IDAgNy43NTQgMS4xMjkgOS45MzQgMy40NTcgMi43NjUgMi45NDUgMy44OTQgNy42OTkgMy44OTQgMTYuMzk2djI3LjIyOWgxNy4wOTh2LTM0LjI2MmMwLTI0LjQ1My0xNS41ODYtMjcuNzUtMzAuODM2LTI3Ljc1SDM1LjE4OHptMTM3LjU4My4wODZsLjAwNyA2MS45MjZoMTcuNDg5di02MS45MjZoLTE3LjQ5NnoiLz48cGF0aCBkPSJNODIuMjExIDEwMi40MTRzMjIuNTA0LTMzLjIwMyA2Ny40MzctMzYuNjM4VjUzLjczYy00OS43NjkgMy45OTctOTIuODY3IDQ2LjE0OS05Mi44NjcgNDYuMTQ5czI0LjQxIDcwLjU2NCA5Mi44NjcgNzcuMDI2di0xMi44MDRjLTUwLjIzNy02LjMyLTY3LjQzNy02MS42ODctNjcuNDM3LTYxLjY4N3ptNjcuNDM3IDM2LjIyM3YxMS43MjdjLTM3Ljk2OC02Ljc3LTQ4LjUwNy00Ni4yMzctNDguNTA3LTQ2LjIzN3MxOC4yMy0yMC4xOTUgNDguNTA3LTIzLjQ3djEyLjg2N2MtLjAyMyAwLS4wMzktLjAwNy0uMDU4LS4wMDctMTUuODkxLTEuOTA3LTI4LjMwNSAxMi45MzgtMjguMzA1IDEyLjkzOHM2Ljk1OCAyNC45OSAyOC4zNjMgMzIuMTgybTAtMTA3LjEyNVY1My43M2MxLjQ2MS0uMTEyIDIuOTIyLS4yMDcgNC4zOTEtLjI1NyA1Ni41ODItMS45MDcgOTMuNDQ5IDQ2LjQwNiA5My40NDkgNDYuNDA2cy00Mi4zNDMgNTEuNDg4LTg2LjQ1NyA1MS40ODhjLTQuMDQzIDAtNy44MjgtLjM3NS0xMS4zODMtMS4wMDV2MTMuNzM5YTc1LjA0IDc1LjA0IDAgMCAwIDkuNDgxLjYxMmM0MS4wNTEgMCA3MC43MzgtMjAuOTY1IDk5LjQ4NC00NS43NzggNC43NjYgMy44MTcgMjQuMjc4IDEzLjEwMyAyOC4yODkgMTcuMTY3LTI3LjMzMiAyMi44ODQtOTEuMDMxIDQxLjMzLTEyNy4xNDQgNDEuMzMtMy40ODEgMC02LjgyNC0uMjExLTEwLjExLS41Mjh2MTkuMzA2SDMwNS42OFYzMS41MTJIMTQ5LjY0OHptMCA0OS4xNDRWNjUuNzc3YzEuNDQ2LS4xMDEgMi45MDMtLjE3OSA0LjM5MS0uMjI2IDQwLjY4OC0xLjI3OCA2Ny4zODIgMzQuOTY1IDY3LjM4MiAzNC45NjVzLTI4LjgzMiA0MC4wNDItNTkuNzQ2IDQwLjA0MmMtNC40NDkgMC04LjQzOC0uNzE1LTEyLjAyOC0xLjkyMlY5My41MjNjMTUuODQgMS45MTQgMTkuMDI4IDguOTExIDI4LjU1MSAyNC43ODZsMjEuMTgxLTE3Ljg1OXMtMTUuNDYxLTIwLjI3Ny00MS41MjQtMjAuMjc3Yy0yLjgzNC0uMDAxLTUuNTQ1LjE5OC04LjIwNy40ODMiIGZpbGw9IiM3N2I5MDAiLz48L3N2Zz4="
' -i Chart.yaml

yq e '
    .icon="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNTAwIiBoZWlnaHQ9IjE4NDEiIHZpZXdCb3g9IjM1LjE4OCAzMS41MTIgMzUxLjQ2IDI1OC43ODUiPjx0aXRsZT5nZW5lcmF0ZWQgYnkgcHN0b2VkaXQgdmVyc2lvbjozLjQ0IGZyb20gTlZCYWRnZV8yRC5lcHM8L3RpdGxlPjxwYXRoIGQ9Ik0zODQuMTk1IDI4Mi4xMDljMCAzLjc3MS0yLjc2OSA2LjMwMi02LjA0NyA2LjMwMnYtLjAyM2MtMy4zNzEuMDIzLTYuMDg5LTIuNTA4LTYuMDg5LTYuMjc4IDAtMy43NjkgMi43MTgtNi4yOTMgNi4wODktNi4yOTMgMy4yNzktLjAwMSA2LjA0NyAyLjUyMyA2LjA0NyA2LjI5MnptMi40NTMgMGMwLTUuMTc2LTQuMDItOC4xOC04LjUtOC4xOC00LjUxMSAwLTguNTMxIDMuMDA0LTguNTMxIDguMTggMCA1LjE3MiA0LjAyMSA4LjE4OCA4LjUzMSA4LjE4OCA0LjQ4IDAgOC41LTMuMDE2IDguNS04LjE4OG0tOS45MS42OTJoLjkxbDIuMTA5IDMuNzAzaDIuMzE1bC0yLjMzNi0zLjg1OWMxLjIwNy0uMDg2IDIuMi0uNjYgMi4yLTIuMjg1IDAtMi4wMi0xLjM5My0yLjY2OC0zLjc1LTIuNjY4aC0zLjQxMXY4LjgxMmgxLjk2MWwuMDAyLTMuNzAzbTAtMS40OTJ2LTIuMTIxaDEuMzY0Yy43NDIgMCAxLjc1My4wNiAxLjc1My45NjUgMCAuOTg0LS41MjMgMS4xNTYtMS4zOTggMS4xNTZoLTEuNzE5TTMyOS40MDYgMjM3LjAyN2wxMC41OTggMjguOTkySDMxOC40OGwxMC45MjYtMjguOTkyem0tMTEuMzUtMTEuMjg5bC0yNC40MjMgNjEuODhoMTcuMjQ1bDMuODYzLTEwLjkzNWgyOC45MDNsMy42NTYgMTAuOTM1aDE4LjcyMmwtMjQuNjA1LTYxLjg4OC0yMy4zNjEuMDA4em0tNDkuMDMzIDYxLjkwM2gxNy40OTd2LTYxLjkyMmwtMTcuNS0uMDA0LjAwMyA2MS45MjZ6bS0xMjEuNDY3LTYxLjkyNmwtMTQuNTk4IDQ5LjA3OC0xMy45ODQtNDkuMDc0LTE4Ljg3OS0uMDA0IDE5Ljk3MiA2MS45MjZoMjUuMjA3bDIwLjEzMy02MS45MjZoLTE3Ljg1MXptNzAuNzI1IDEzLjQ4NGg3LjUyMWMxMC45MDkgMCAxNy45NjYgNC44OTggMTcuOTY2IDE3LjYwOSAwIDEyLjcxMy03LjA1NyAxNy42MTItMTcuOTY2IDE3LjYxMmgtNy41MjF2LTM1LjIyMXptLTE3LjM1LTEzLjQ4NHY2MS45MjZoMjguMzY1YzE1LjExMyAwIDIwLjA0OS0yLjUxMiAyNS4zODUtOC4xNDcgMy43NjktMy45NTcgNi4yMDctMTIuNjQyIDYuMjA3LTIyLjEzNCAwLTguNzA3LTIuMDYzLTE2LjQ2OS01LjY2LTIxLjMwNS02LjQ4LTguNjQ4LTE1LjgxNi0xMC4zNC0yOS43NS0xMC4zNGgtMjQuNTQ3em0tMTY1Ljc0My0uMDg2djYyLjAxMmgxNy42NDV2LTQ3LjA4NmwxMy42NzIuMDA0YzQuNTI3IDAgNy43NTQgMS4xMjkgOS45MzQgMy40NTcgMi43NjUgMi45NDUgMy44OTQgNy42OTkgMy44OTQgMTYuMzk2djI3LjIyOWgxNy4wOTh2LTM0LjI2MmMwLTI0LjQ1My0xNS41ODYtMjcuNzUtMzAuODM2LTI3Ljc1SDM1LjE4OHptMTM3LjU4My4wODZsLjAwNyA2MS45MjZoMTcuNDg5di02MS45MjZoLTE3LjQ5NnoiLz48cGF0aCBkPSJNODIuMjExIDEwMi40MTRzMjIuNTA0LTMzLjIwMyA2Ny40MzctMzYuNjM4VjUzLjczYy00OS43NjkgMy45OTctOTIuODY3IDQ2LjE0OS05Mi44NjcgNDYuMTQ5czI0LjQxIDcwLjU2NCA5Mi44NjcgNzcuMDI2di0xMi44MDRjLTUwLjIzNy02LjMyLTY3LjQzNy02MS42ODctNjcuNDM3LTYxLjY4N3ptNjcuNDM3IDM2LjIyM3YxMS43MjdjLTM3Ljk2OC02Ljc3LTQ4LjUwNy00Ni4yMzctNDguNTA3LTQ2LjIzN3MxOC4yMy0yMC4xOTUgNDguNTA3LTIzLjQ3djEyLjg2N2MtLjAyMyAwLS4wMzktLjAwNy0uMDU4LS4wMDctMTUuODkxLTEuOTA3LTI4LjMwNSAxMi45MzgtMjguMzA1IDEyLjkzOHM2Ljk1OCAyNC45OSAyOC4zNjMgMzIuMTgybTAtMTA3LjEyNVY1My43M2MxLjQ2MS0uMTEyIDIuOTIyLS4yMDcgNC4zOTEtLjI1NyA1Ni41ODItMS45MDcgOTMuNDQ5IDQ2LjQwNiA5My40NDkgNDYuNDA2cy00Mi4zNDMgNTEuNDg4LTg2LjQ1NyA1MS40ODhjLTQuMDQzIDAtNy44MjgtLjM3NS0xMS4zODMtMS4wMDV2MTMuNzM5YTc1LjA0IDc1LjA0IDAgMCAwIDkuNDgxLjYxMmM0MS4wNTEgMCA3MC43MzgtMjAuOTY1IDk5LjQ4NC00NS43NzggNC43NjYgMy44MTcgMjQuMjc4IDEzLjEwMyAyOC4yODkgMTcuMTY3LTI3LjMzMiAyMi44ODQtOTEuMDMxIDQxLjMzLTEyNy4xNDQgNDEuMzMtMy40ODEgMC02LjgyNC0uMjExLTEwLjExLS41Mjh2MTkuMzA2SDMwNS42OFYzMS41MTJIMTQ5LjY0OHptMCA0OS4xNDRWNjUuNzc3YzEuNDQ2LS4xMDEgMi45MDMtLjE3OSA0LjM5MS0uMjI2IDQwLjY4OC0xLjI3OCA2Ny4zODIgMzQuOTY1IDY3LjM4MiAzNC45NjVzLTI4LjgzMiA0MC4wNDItNTkuNzQ2IDQwLjA0MmMtNC40NDkgMC04LjQzOC0uNzE1LTEyLjAyOC0xLjkyMlY5My41MjNjMTUuODQgMS45MTQgMTkuMDI4IDguOTExIDI4LjU1MSAyNC43ODZsMjEuMTgxLTE3Ljg1OXMtMTUuNDYxLTIwLjI3Ny00MS41MjQtMjAuMjc3Yy0yLjgzNC0uMDAxLTUuNTQ1LjE5OC04LjIwNy40ODMiIGZpbGw9IiM3N2I5MDAiLz48L3N2Zz4="
' -i charts/hami/Chart.yaml

# update email
yq -i '
    .maintainers=[]
' Chart.yaml
yq -i '
    .maintainers=[]
' charts/hami/Chart.yaml

# rm daemonsethygon.yaml file
#rm -rf charts/hami/templates/device-plugin/daemonsethygon.yaml

yq -i '.scheduler.serviceMonitor.enable=false' charts/hami/values.yaml

yq -i '.hami.scheduler.serviceMonitor.enable=false' values.yaml

# Prevent users from overriding scheduler-injected GPU envs such as
# NVIDIA_VISIBLE_DEVICES.
yq -i '.scheduler.overwriteEnv="true"' charts/hami/values.yaml

yq -i '.hami.scheduler.overwriteEnv="true"' values.yaml

if [ -f charts/hami/templates/scheduler/device-configmap.yaml ]; then
    if [ $os == "Darwin" ];then
        sed -i "" 's/default "false"/default "true"/g' charts/hami/templates/scheduler/device-configmap.yaml
    elif [ $os == "Linux" ];then
        sed -i 's/default "false"/default "true"/g' charts/hami/templates/scheduler/device-configmap.yaml
    fi
fi

if [ -f charts/hami/charts/hami-dra/templates/webhook/device-config.yaml ]; then
    if [ $os == "Darwin" ];then
        sed -i "" "s/overwriteEnv: false/overwriteEnv: true/g" charts/hami/charts/hami-dra/templates/webhook/device-config.yaml
    elif [ $os == "Linux" ];then
        sed -i "s/overwriteEnv: false/overwriteEnv: true/g" charts/hami/charts/hami-dra/templates/webhook/device-config.yaml
    fi
fi

yq -i '.devicePlugin.deviceCoreScaling=1.0' charts/hami/values.yaml

yq -i '.hami.devicePlugin.deviceCoreScaling=1.0' values.yaml

yq -i '.devicePlugin.deviceMemoryScaling=1.0' charts/hami/values.yaml

yq -i '.hami.devicePlugin.deviceMemoryScaling=1.0' values.yaml

yq -i '
  .hami.scheduler.kubeScheduler.resources.limits.cpu = "500m" |
  .hami.scheduler.kubeScheduler.resources.limits.memory = "720Mi" |
  .hami.scheduler.kubeScheduler.resources.requests.cpu = "100m" |
  .hami.scheduler.kubeScheduler.resources.requests.memory = "128Mi"
' values.yaml

yq -i '
  .hami.scheduler.extender.resources.limits.cpu = "500m" |
  .hami.scheduler.extender.resources.limits.memory = "720Mi" |
  .hami.scheduler.extender.resources.requests.cpu = "100m" |
  .hami.scheduler.extender.resources.requests.memory = "128Mi"
' values.yaml

yq -i '
  .hami.devicePlugin.resources.limits.cpu = "500m" |
  .hami.devicePlugin.resources.limits.memory = "720Mi" |
  .hami.devicePlugin.resources.requests.cpu = "100m" |
  .hami.devicePlugin.resources.requests.memory = "128Mi"
' values.yaml

yq -i '
  .hami.devicePlugin.monitor.resources.limits.cpu = "500m" |
  .hami.devicePlugin.monitor.resources.limits.memory = "720Mi" |
  .hami.devicePlugin.monitor.resources.requests.cpu = "100m" |
  .hami.devicePlugin.monitor.resources.requests.memory = "128Mi"
' values.yaml
yq -i '
  .hami.devicePlugin.vgpuMonitor.resources.limits.cpu = "500m" |
  .hami.devicePlugin.vgpuMonitor.resources.limits.memory = "720Mi" |
  .hami.devicePlugin.vgpuMonitor.resources.requests.cpu = "100m" |
  .hami.devicePlugin.vgpuMonitor.resources.requests.memory = "128Mi"
' values.yaml


# update devicePlugin.registry to release.daocloud.io, from 2.5.1 version use hami repo
#yq -i '.hami.devicePlugin.registry="release.daocloud.io"' values.yaml
#yq -i '.devicePlugin.registry="release.daocloud.io"' charts/hami/values.yaml


# image.tag 留空，写成固定值会关掉推导链：compatibility -> image.tag -> 按集群版本推导
SCHED_TAG_COMMENT="leave empty: overriding it disables both the compatibility lookup and the upstream per-cluster derivation"
yq -i "
  .hami.scheduler.kubeScheduler.image.tag=\"\" |
  .hami.scheduler.kubeScheduler.image.tag lineComment=\"${SCHED_TAG_COMMENT}\"
" values.yaml
yq -i "
  .scheduler.kubeScheduler.image.tag=\"\" |
  .scheduler.kubeScheduler.image.tag lineComment=\"${SCHED_TAG_COMMENT}\"
" charts/hami/values.yaml


# compatibility 表：声明可离线持久化的 scheduler 镜像，同时作为推导结果的收敛点。
# 上游推导出的是集群精确 patch 版本（无界），relok8s 只能持久化有限集合，两者必须对齐。
# skew 允许 scheduler 比 apiserver 旧一个小版本，故一个 tag 覆盖 N / N+1，1.22~1.33 需 6 个。
# 新增 k8s 版本时同步追加 parent/.relok8s-images.yaml。
SCHED_COMPATIBILITY="122:v1.22.0 124:v1.24.0 126:v1.26.0 128:v1.28.0 130:v1.30.0 132:v1.32.0"
for entry in ${SCHED_COMPATIBILITY}; do
    minor="${entry%%:*}"
    tag="${entry##*:}"
    yq -i ".hami.scheduler.kubeScheduler.compatibility.kube_gte_${minor}=\"${tag}\"" values.yaml
    yq -i ".scheduler.kubeScheduler.compatibility.kube_gte_${minor}=\"${tag}\"" charts/hami/values.yaml
done
SCHED_COMPAT_COMMENT="kube-scheduler image per cluster version: the greatest kube_gte_<minor> not above the running cluster wins, so the scheduler stays within one minor of the apiserver. Every tag is declared here so .relok8s-images.yaml can resolve it statically for offline relocation."
yq -i ".hami.scheduler.kubeScheduler.compatibility headComment=\"${SCHED_COMPAT_COMMENT}\"" values.yaml
yq -i ".scheduler.kubeScheduler.compatibility headComment=\"${SCHED_COMPAT_COMMENT}\"" charts/hami/values.yaml


# resolvedKubeSchedulerTag: 先查 compatibility，再回落 image.tag，最后回落集群版本
target_file="charts/hami/templates/_helpers.tpl"
if [ -f "$target_file" ]; then
  tmp_out="$(mktemp)"
  awk '
    /^\{\{- define "resolvedKubeSchedulerTag" -\}\}$/ {
      print "{{- define \"resolvedKubeSchedulerTag\" -}}"
      print "{{- $cur := printf \"1%s\" (regexReplaceAll \"[^0-9]\" .Capabilities.KubeVersion.Minor \"\") | int -}}"
      print "{{- $best := -1 -}}"
      print "{{- $selected := \"\" -}}"
      print "{{- range $key, $val := (.Values.scheduler.kubeScheduler.compatibility | default dict) -}}"
      print "{{- $threshold := regexReplaceAll \"[^0-9]\" $key \"\" | int -}}"
      print "{{- if and (le $threshold $cur) (gt $threshold $best) -}}"
      print "{{- $best = $threshold -}}"
      print "{{- $selected = $val -}}"
      print "{{- end -}}"
      print "{{- end -}}"
      print "{{- if $selected }}"
      print "{{- $selected | trim -}}"
      print "{{- else if .Values.scheduler.kubeScheduler.image.tag }}"
      print "{{- .Values.scheduler.kubeScheduler.image.tag | trim -}}"
      print "{{- else }}"
      print "{{- include \"strippedKubeVersion\" . | trim -}}"
      print "{{- end }}"
      print "{{- end }}"
      skip = 1
      ends = 0
      next
    }
    skip == 1 {
      if ($0 ~ /^\{\{- end \}\}$/) { ends++ ; if (ends == 2) skip = 0 }
      next
    }
    { print }
  ' "$target_file" > "$tmp_out" && mv "$tmp_out" "$target_file"
fi


# 配置格式必须跟随实际选中的二进制，而非集群版本：v1beta2 在 kube-scheduler 1.28 已移除
target_file="charts/hami/templates/scheduler/configmap.yaml"
if [ -f "$target_file" ]; then
  tmp_out="$(mktemp)"
  awk '
    /^\{\{- \$k8sMinor := / {
      print "{{- $schedTag := include \"resolvedKubeSchedulerTag\" . -}}"
      print "{{- $k8sMinor := index (splitList \".\" (trimPrefix \"v\" $schedTag)) 1 | int -}}"
      next
    }
    { print }
  ' "$target_file" > "$tmp_out" && mv "$tmp_out" "$target_file"
fi

# 启动参数的新旧选择同理
target_file="charts/hami/templates/scheduler/deployment.yaml"
if [ -f "$target_file" ]; then
  tmp_out="$(mktemp)"
  awk '
    index($0, "{{- if ge (regexReplaceAll \"[^0-9]\" .Capabilities.KubeVersion.Minor \"\" | int) 22 }}") > 0 {
      print "            {{- if ge (index (splitList \".\" (trimPrefix \"v\" (include \"resolvedKubeSchedulerTag\" .))) 1 | int) 22 }}"
      next
    }
    { print }
  ' "$target_file" > "$tmp_out" && mv "$tmp_out" "$target_file"
fi


# ---- Inject Helm logic into scheduler ClusterRoleBinding roleRef.name ----
target_file="charts/hami/templates/scheduler/clusterrolebinding.yaml"
if [ -f "$target_file" ]; then
  tmp_block="$(mktemp)"
  cat > "$tmp_block" <<'EOF'
  {{- $crbName := include "hami-vgpu.scheduler" . }}
  {{- $existing := lookup "rbac.authorization.k8s.io/v1" "ClusterRoleBinding" "" $crbName }}
  {{- $keepClusterAdmin := and .Release.IsUpgrade (and $existing (eq $existing.roleRef.name "cluster-admin")) }}
  name: {{ ternary "cluster-admin" (include "hami-vgpu.scheduler" .) $keepClusterAdmin }}
EOF
  tmp_out="$(mktemp)"
  awk -v blockfile="$tmp_block" '
    BEGIN {
      while ((getline line < blockfile) > 0) {
        block[++n] = line
      }
      close(blockfile)
    }
    {
      if ($0 == "  name: hami-scheduler") {
        for (i = 1; i <= n; i++) print block[i]
        next
      }
      print
    }
  ' "$target_file" > "$tmp_out" && mv "$tmp_out" "$target_file"
  rm -f "$tmp_block"
fi
