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

# sed resourceName: "nvidia.com/gpu" to resourceName: "nvidia.com/vgpu"

if [ $os == "Darwin" ];then
    sed -i "" "s/resourceName: \"nvidia.com\/gpu\"/resourceName: \"nvidia.com\/vgpu\"/g" values.yaml
elif [ $os == "Linux" ];then
    sed -i "s/resourceName: \"nvidia.com\/gpu\"/resourceName: \"nvidia.com\/vgpu\"/g" values.yaml
fi


# sed scheduler.kubeScheduler.registry and scheduler.kubeScheduler.repository
line=`sed -n -e '/image: registry.cn-hangzhou/=' values.yaml`
if [ $os == "Darwin" ];then
     sed -i "" "$line"d values.yaml
     sed -i "" "$line i\\
      registry: k8s-gcr.m.daocloud.io
      " values.yaml
     sed -i "" "$((line+1)) i\\
      repository: kubernetes/kube-scheduler
      " values.yaml
      sed -i "" "s/image: \"{{ .Values.scheduler.kubeScheduler.image }}:{{ include \"resolvedKubeSchedulerTag\" . }}\"/image: \"{{ .Values.scheduler.kubeScheduler.registry }}\/{{ .Values.scheduler.kubeScheduler.repository }}:{{ .Values.scheduler.kubeScheduler.imageTag }}\"/" charts/hami/templates/scheduler/deployment.yaml
elif [ $os == "Linux" ];then
     sed -i "$line"d values.yaml
     sed -i "$line i\\
      registry: k8s-gcr.m.daocloud.io
           " values.yaml
     sed -i "$((line+1)) i\\
      repository: kubernetes/kube-scheduler
           " values.yaml
    sed -i "s/image: \"{{ .Values.scheduler.kubeScheduler.image }}:{{ include \"resolvedKubeSchedulerTag\" . }}\"/image: \"{{ .Values.scheduler.kubeScheduler.registry }}\/{{ .Values.scheduler.kubeScheduler.repository }}:{{ .Values.scheduler.kubeScheduler.imageTag }}\"/" charts/hami/templates/scheduler/deployment.yaml
fi

# set scheduler imageTag v1.20.0 to "v1.28.0"
if [ $os == "Darwin" ];then
        sed -i "" "s/imageTag: \"v1.20.0\"/imageTag: \"v1.28.0\"/g" values.yaml
elif [ $os == "Linux" ];then
        sed -i "s/imageTag: \"v1.20.0\"/imageTag: \"v1.28.0\"/g" values.yaml
fi

# sed scheduler.extender.image
line=$(sed -n -e '/ image: "projecthami\/hami"/=' values.yaml  | head -n 1)
if [ $os == "Darwin" ];then
     sed -i "" "$line"d values.yaml
     sed -i "" "$line i\\
      registry: docker.m.daocloud.io
          " values.yaml
     sed -i "" "$((line+1)) i\\
      repository: projecthami/hami
           " values.yaml
     sed -i "" "s/image: {{ .Values.scheduler.extender.image }}:{{ .Values.version }}/image: \"{{ .Values.scheduler.extender.registry }}\/{{ .Values.scheduler.extender.repository }}:{{ .Values.version }}\"/" charts/hami/templates/scheduler/deployment.yaml
elif [ $os == "Linux" ];then
    sed -i "$line"d values.yaml
    sed -i  "$line i\\
      registry: docker.m.daocloud.io
            " values.yaml
    sed -i  "$((line+1)) i\\
      repository: projecthami/hami
            " values.yaml
    sed -i  "s/image: {{ .Values.scheduler.extender.image }}:{{ .Values.version }}/image: \"{{ .Values.scheduler.extender.registry }}\/{{ .Values.scheduler.extender.repository }}:{{ .Values.version }}\"/" charts/hami/templates/scheduler/deployment.yaml
fi


line=$(sed -n -e '/ image: "projecthami\/hami"/=' values.yaml  | head -n 1)
if [ $os == "Darwin" ];then
     sed -i "" "$line"d values.yaml
     sed -i "" "$line i\\
    registry: docker.m.daocloud.io
          " values.yaml
     sed -i "" "$((line+1)) i\\
    repository: projecthami/hami
           " values.yaml
     sed -i "" "s/image: {{ .Values.devicePlugin.image }}:{{ .Values.version }}/image: \"{{ .Values.devicePlugin.registry }}\/{{ .Values.devicePlugin.repository }}:{{ .Values.version }}\"/" charts/hami/templates/device-plugin/daemonsetnvidia.yaml
elif [ $os == "Linux" ];then
    sed -i "$line"d values.yaml
    sed -i  "$line i\\
    registry: docker.m.daocloud.io
            " values.yaml
    sed -i  "$((line+1)) i\\
    repository: projecthami/hami
            " values.yaml
    sed -i  "s/image: {{ .Values.devicePlugin.image }}:{{ .Values.version }}/image: \"{{ .Values.devicePlugin.registry }}\/{{ .Values.devicePlugin.repository }}:{{ .Values.version }}\"/" charts/hami/templates/device-plugin/daemonsetnvidia.yaml
fi

# sed patch image
line=$(sed -n -e '/ image: docker.io\/jettech\/kube-webhook-certgen/=' values.yaml  | head -n 1)
if [ $os == "Darwin" ];then
     sed -i "" "$line"d values.yaml
     sed -i "" "$line i\\
      registry: docker.m.daocloud.io
          " values.yaml
     sed -i "" "$((line+1)) i\\
      repository: jettech/kube-webhook-certgen
           " values.yaml
     sed -i "" "$((line+2)) i\\
      tag: v1.5.2
          " values.yaml
     sed -i "" "s/image: {{ .Values.scheduler.patch.image }}/image: \"{{ .Values.scheduler.patch.registry }}\/{{ .Values.scheduler.patch.repository }}:{{ .Values.scheduler.patch.tag }}\"/" charts/hami/templates/scheduler/job-patch/job-createSecret.yaml
     sed -i "" "s/image: {{ .Values.scheduler.patch.image }}/image: \"{{ .Values.scheduler.patch.registry }}\/{{ .Values.scheduler.patch.repository }}:{{ .Values.scheduler.patch.tag }}\"/" charts/hami/templates/scheduler/job-patch/job-patchWebhook.yaml
elif [ $os == "Linux" ];then
    sed -i "$line"d values.yaml
    sed -i  "$line i\\
      registry: docker.m.daocloud.io
            " values.yaml
    sed -i  "$((line+1)) i\\
      repository: jettech/kube-webhook-certgen
            " values.yaml
    sed -i "$((line+2)) i\\
      tag: v1.5.2
              " values.yaml
    sed -i  "s/image: {{ .Values.scheduler.patch.image }}/image: \"{{ .Values.scheduler.patch.registry }}\/{{ .Values.scheduler.patch.repository }}:{{ .Values.scheduler.patch.tag }}\"/" charts/hami/templates/scheduler/job-patch/job-createSecret.yaml
    sed -i  "s/image: {{ .Values.scheduler.patch.image }}/image: \"{{ .Values.scheduler.patch.registry }}\/{{ .Values.scheduler.patch.repository }}:{{ .Values.scheduler.patch.tag }}\"/" charts/hami/templates/scheduler/job-patch/job-patchWebhook.yaml
fi

# sed patch imageNew
line=$(sed -n -e '/ imageNew: liangjw\/kube-webhook-certgen/=' values.yaml  | head -n 1)
if [ $os == "Darwin" ];then
    sed -i "" "$line"d values.yaml
     sed -i "" "$((line)) i\\
      newRepository: liangjw/kube-webhook-certgen
           " values.yaml
     sed -i "" "$((line+1)) i\\
      newTag: v1.1.1
          " values.yaml
    sed -i "" "s/image: {{ .Values.scheduler.patch.imageNew }}/image: \"{{ .Values.scheduler.patch.registry }}\/{{ .Values.scheduler.patch.newRepository }}:{{ .Values.scheduler.patch.newTag }}\"/" charts/hami/templates/scheduler/job-patch/job-createSecret.yaml
    sed -i "" "s/image: {{ .Values.scheduler.patch.imageNew }}/image: \"{{ .Values.scheduler.patch.registry }}\/{{ .Values.scheduler.patch.newRepository }}:{{ .Values.scheduler.patch.newTag }}\"/" charts/hami/templates/scheduler/job-patch/job-patchWebhook.yaml
elif [ $os == "Linux" ];then
     sed -i "$line"d values.yaml
     sed -i  "$((line)) i\\
      newRepository: liangjw/kube-webhook-certgen
           " values.yaml
     sed -i  "$((line+1)) i\\
      newTag: v1.1.1
          " values.yaml
    sed -i  "s/image: {{ .Values.scheduler.patch.imageNew }}/image: \"{{ .Values.scheduler.patch.registry }}\/{{ .Values.scheduler.patch.newRepository }}:{{ .Values.scheduler.patch.newTag }}\"/" charts/hami/templates/scheduler/job-patch/job-createSecret.yaml
    sed -i  "s/image: {{ .Values.scheduler.patch.imageNew }}/image: \"{{ .Values.scheduler.patch.registry }}\/{{ .Values.scheduler.patch.newRepository }}:{{ .Values.scheduler.patch.newTag }}\"/" charts/hami/templates/scheduler/job-patch/job-patchWebhook.yaml
fi

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


# add resources deployment.yaml
line=$(sed -n -e '/volumeMounts:/=' charts/hami/templates/scheduler/deployment.yaml | head -n 1)
  echo "Processing line number: $line"
  if [ $os == "Darwin" ];then
     sed -i "" "$((line)) i\\
          resources: {{ toYaml .Values.resources | nindent 12 }}
      " charts/hami/templates/scheduler/deployment.yaml
  elif [ $os == "Linux" ];then
    sed -i "$((line)) i\\
          resources: {{ toYaml .Values.resources | nindent 12 }}
    " charts/hami/templates/scheduler/deployment.yaml
  fi



line=$(sed -n -e '/volumeMounts:/=' charts/hami/templates/scheduler/deployment.yaml | sed -n '2p')
  echo "Processing line number: $line"
  if [ $os == "Darwin" ];then
     sed -i "" "$((line)) i\\
          resources: {{ toYaml .Values.resources | nindent 12 }}
      " charts/hami/templates/scheduler/deployment.yaml
  elif [ $os == "Linux" ];then
    sed -i "$((line)) i\\
          resources: {{ toYaml .Values.resources | nindent 12 }}
    " charts/hami/templates/scheduler/deployment.yaml
  fi


# add resources daemonsetnvidia.yaml
line=$(sed -n -e '/volumeMounts:/=' charts/hami/templates/device-plugin/daemonsetnvidia.yaml  | head -n 1)
  if [ $os == "Darwin" ];then
     sed -i "" "$((line)) i\\
          resources: {{ toYaml .Values.resources | nindent 12 }}
      " charts/hami/templates/device-plugin/daemonsetnvidia.yaml
  elif [ $os == "Linux" ];then
    sed -i "$((line)) i\\
          resources: {{ toYaml .Values.resources | nindent 12 }}
    " charts/hami/templates/device-plugin/daemonsetnvidia.yaml
  fi


# add resources to values.yaml
cat >> values.yaml << EOL
  resources:
    limits:
      cpu: 500m
      memory: 720Mi
    requests:
      cpu: 100m
      memory: 128Mi
EOL

# update chart name hami to nvidia-vgpu
if [ $os == "Darwin" ];then
    sed -i "" "s/name: hami/name: nvidia-vgpu/g" Chart.yaml
    sed -i "" "s/- name: nvidia-vgpu/- name: hami/g" Chart.yaml
elif [ $os == "Linux" ];then
    sed -i "s/name: hami/name: nvidia-vgpu/g" Chart.yaml
    sed -i "s/- name: nvidia-vgpu/- name: hami/g" Chart.yaml
fi
# update chart version
if [ $os == "Darwin" ];then
    sed -i "" "s/^version: .*$/version: ${CUSTOM_VERSION}/g" Chart.yaml
elif [ $os == "Linux" ];then
    sed -i "s/^version: .*$/version: ${CUSTOM_VERSION}/g" Chart.yaml
fi
# update nvidianodeSelector values
yq -i '
    .hami.devicePlugin.nvidianodeSelector={"nvidia.com/gpu.deploy.container-toolkit":"true", "nvidia.com/vgpu.deploy.device-plugin": "true"} |
    .hami.scheduler.nodeSelector={"nvidia.com/gpu.deploy.container-toolkit":"true"}
' values.yaml
yq -i '
    .devicePlugin.nvidianodeSelector={"nvidia.com/gpu.deploy.container-toolkit":"true", "nvidia.com/vgpu.deploy.device-plugin": "true"} |
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

yq -i '.devicePlugin.deviceCoreScaling=1.0' charts/hami/values.yaml

yq -i '.hami.devicePlugin.deviceCoreScaling=1.0' values.yaml

yq -i '.devicePlugin.deviceMemoryScaling=1.0' charts/hami/values.yaml

yq -i '.hami.devicePlugin.deviceMemoryScaling=1.0' values.yaml


# update devicePlugin.registry to release.daocloud.io, from 2.5.1 version use hami repo
#yq -i '.hami.devicePlugin.registry="release.daocloud.io"' values.yaml
#yq -i '.devicePlugin.registry="release.daocloud.io"' charts/hami/values.yaml


yq -i '.hami.scheduler.kubeScheduler.imageTag="v1.28.0"' values.yaml
yq -i '.hami.scheduler.kubeScheduler.imageTag="v1.28.0"' charts/hami/values.yaml