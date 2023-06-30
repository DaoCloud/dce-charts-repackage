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
      sed -i "" "s/image: {{ .Values.scheduler.kubeScheduler.image }}:{{ .Values.scheduler.kubeScheduler.imageTag }}/image: \"{{ .Values.scheduler.kubeScheduler.registry }}\/{{ .Values.scheduler.kubeScheduler.repository }}:{{ .Values.scheduler.kubeScheduler.imageTag }}\"/" charts/vgpu/templates/scheduler/deployment.yaml
elif [ $os == "Linux" ];then
     sed -i "$line"d values.yaml
     sed -i "$line i\\
      registry: k8s-gcr.m.daocloud.io
           " values.yaml
     sed -i "$((line+1)) i\\
      repository: kubernetes/kube-scheduler
           " values.yaml
    sed -i "s/image: {{ .Values.scheduler.kubeScheduler.image }}:{{ .Values.scheduler.kubeScheduler.imageTag }}/image: \"{{ .Values.scheduler.kubeScheduler.registry }}\/{{ .Values.scheduler.kubeScheduler.repository }}:{{ .Values.scheduler.kubeScheduler.imageTag }}\"/" charts/vgpu/templates/scheduler/deployment.yaml
fi

# set scheduler imageTag v1.20.0 to "v1.24.0"
if [ $os == "Darwin" ];then
        sed -i "" "s/imageTag: \"v1.20.0\"/imageTag: \"v1.24.0\"/g" values.yaml
elif [ $os == "Linux" ];then
        sed -i "s/imageTag: \"v1.20.0\"/imageTag: \"v1.24.0\"/g" values.yaml
fi

# sed scheduler.extender.image
line=$(sed -n -e '/ image: "4pdosc\/k8s-vdevice"/=' values.yaml  | head -n 1)
if [ $os == "Darwin" ];then
     sed -i "" "$line"d values.yaml
     sed -i "" "$line i\\
      registry: docker.m.daocloud.io
          " values.yaml
     sed -i "" "$((line+1)) i\\
      repository: 4pdosc/k8s-vdevice
           " values.yaml
     sed -i "" "s/image: {{ .Values.scheduler.extender.image }}:{{ .Values.version }}/image: \"{{ .Values.scheduler.extender.registry }}\/{{ .Values.scheduler.extender.repository }}:{{ .Values.version }}\"/" charts/vgpu/templates/scheduler/deployment.yaml
elif [ $os == "Linux" ];then
    sed -i "$line"d values.yaml
    sed -i  "$line i\\
      registry: docker.m.daocloud.io
            " values.yaml
    sed -i  "$((line+1)) i\\
      repository: 4pdosc/k8s-vdevice
            " values.yaml
    sed -i  "s/image: {{ .Values.scheduler.extender.image }}:{{ .Values.version }}/image: \"{{ .Values.scheduler.extender.registry }}\/{{ .Values.scheduler.extender.repository }}:{{ .Values.version }}\"/" charts/vgpu/templates/scheduler/deployment.yaml
fi


line=$(sed -n -e '/ image: "4pdosc\/k8s-vdevice"/=' values.yaml  | head -n 1)
if [ $os == "Darwin" ];then
     sed -i "" "$line"d values.yaml
     sed -i "" "$line i\\
    registry: docker.m.daocloud.io
          " values.yaml
     sed -i "" "$((line+1)) i\\
    repository: 4pdosc/k8s-vdevice
           " values.yaml
     sed -i "" "s/image: {{ .Values.devicePlugin.image }}:{{ .Values.version }}/image: \"{{ .Values.devicePlugin.registry }}\/{{ .Values.devicePlugin.repository }}:{{ .Values.version }}\"/" charts/vgpu/templates/device-plugin/daemonsetmlu.yaml
     sed -i "" "s/image: {{ .Values.devicePlugin.image }}:{{ .Values.version }}/image: \"{{ .Values.devicePlugin.registry }}\/{{ .Values.devicePlugin.repository }}:{{ .Values.version }}\"/" charts/vgpu/templates/device-plugin/daemonsetnvidia.yaml
elif [ $os == "Linux" ];then
    sed -i "$line"d values.yaml
    sed -i  "$line i\\
    registry: docker.m.daocloud.io
            " values.yaml
    sed -i  "$((line+1)) i\\
    repository: 4pdosc/k8s-vdevice
            " values.yaml
    sed -i  "s/image: {{ .Values.devicePlugin.image }}:{{ .Values.version }}/image: \"{{ .Values.devicePlugin.registry }}\/{{ .Values.devicePlugin.repository }}:{{ .Values.version }}\"/" charts/vgpu/templates/device-plugin/daemonsetmlu.yaml
    sed -i  "s/image: {{ .Values.devicePlugin.image }}:{{ .Values.version }}/image: \"{{ .Values.devicePlugin.registry }}\/{{ .Values.devicePlugin.repository }}:{{ .Values.version }}\"/" charts/vgpu/templates/device-plugin/daemonsetnvidia.yaml
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
     sed -i "" "s/image: {{ .Values.scheduler.patch.image }}/image: \"{{ .Values.scheduler.patch.registry }}\/{{ .Values.scheduler.patch.repository }}:{{ .Values.scheduler.patch.tag }}\"/" charts/vgpu/templates/scheduler/job-patch/job-createSecret.yaml
     sed -i "" "s/image: {{ .Values.scheduler.patch.image }}/image: \"{{ .Values.scheduler.patch.registry }}\/{{ .Values.scheduler.patch.repository }}:{{ .Values.scheduler.patch.tag }}\"/" charts/vgpu/templates/scheduler/job-patch/job-patchWebhook.yaml
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
    sed -i  "s/image: {{ .Values.scheduler.patch.image }}/image: \"{{ .Values.scheduler.patch.registry }}\/{{ .Values.scheduler.patch.repository }}:{{ .Values.scheduler.patch.tag }}\"/" charts/vgpu/templates/scheduler/job-patch/job-createSecret.yaml
    sed -i  "s/image: {{ .Values.scheduler.patch.image }}/image: \"{{ .Values.scheduler.patch.registry }}\/{{ .Values.scheduler.patch.repository }}:{{ .Values.scheduler.patch.tag }}\"/" charts/vgpu/templates/scheduler/job-patch/job-patchWebhook.yaml
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
    sed -i "" "s/image: {{ .Values.scheduler.patch.imageNew }}/image: \"{{ .Values.scheduler.patch.registry }}\/{{ .Values.scheduler.patch.newRepository }}:{{ .Values.scheduler.patch.newTag }}\"/" charts/vgpu/templates/scheduler/job-patch/job-createSecret.yaml
    sed -i "" "s/image: {{ .Values.scheduler.patch.imageNew }}/image: \"{{ .Values.scheduler.patch.registry }}\/{{ .Values.scheduler.patch.newRepository }}:{{ .Values.scheduler.patch.newTag }}\"/" charts/vgpu/templates/scheduler/job-patch/job-patchWebhook.yaml
elif [ $os == "Linux" ];then
     sed -i "$line"d values.yaml
     sed -i  "$((line)) i\\
      newRepository: liangjw/kube-webhook-certgen
           " values.yaml
     sed -i  "$((line+1)) i\\
      newTag: v1.1.1
          " values.yaml
    sed -i  "s/image: {{ .Values.scheduler.patch.imageNew }}/image: \"{{ .Values.scheduler.patch.registry }}\/{{ .Values.scheduler.patch.newRepository }}:{{ .Values.scheduler.patch.newTag }}\"/" charts/vgpu/templates/scheduler/job-patch/job-createSecret.yaml
    sed -i  "s/image: {{ .Values.scheduler.patch.imageNew }}/image: \"{{ .Values.scheduler.patch.registry }}\/{{ .Values.scheduler.patch.newRepository }}:{{ .Values.scheduler.patch.newTag }}\"/" charts/vgpu/templates/scheduler/job-patch/job-patchWebhook.yaml
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
line=$(sed -n -e '/volumeMounts:/=' charts/vgpu/templates/scheduler/deployment.yaml | head -n 1)
  echo "Processing line number: $line"
  if [ $os == "Darwin" ];then
     sed -i "" "$((line)) i\\
          resources: {{ toYaml .Values.resources | nindent 12 }}
      " charts/vgpu/templates/scheduler/deployment.yaml
  elif [ $os == "Linux" ];then
    sed -i "$((line)) i\\
          resources: {{ toYaml .Values.resources | nindent 12 }}
    " charts/vgpu/templates/scheduler/deployment.yaml
  fi

line=$(sed -n -e '/volumeMounts:/=' charts/vgpu/templates/scheduler/deployment.yaml | sed -n '2p')
  echo "Processing line number: $line"
  if [ $os == "Darwin" ];then
     sed -i "" "$((line)) i\\
          resources: {{ toYaml .Values.resources | nindent 12 }}
      " charts/vgpu/templates/scheduler/deployment.yaml
  elif [ $os == "Linux" ];then
    sed -i "$((line)) i\\
          resources: {{ toYaml .Values.resources | nindent 12 }}
    " charts/vgpu/templates/scheduler/deployment.yaml
  fi

# add resoource daemonsetmlu.yaml
line=$(sed -n -e '/volumeMounts:/=' charts/vgpu/templates/device-plugin/daemonsetmlu.yaml  | head -n 1)
  echo "Processing line number: $line"
  if [ $os == "Darwin" ];then
     sed -i "" "$((line)) i\\
          resources: {{ toYaml .Values.resources | nindent 12 }}
      " charts/vgpu/templates/device-plugin/daemonsetmlu.yaml
  elif [ $os == "Linux" ];then
    sed -i "$((line)) i\\
          resources: {{ toYaml .Values.resources | nindent 12 }}
    " charts/vgpu/templates/device-plugin/daemonsetmlu.yaml
  fi

# add resources daemonsetnvidia.yaml
line=$(sed -n -e '/volumeMounts:/=' charts/vgpu/templates/device-plugin/daemonsetnvidia.yaml  | head -n 1)
  if [ $os == "Darwin" ];then
     sed -i "" "$((line)) i\\
          resources: {{ toYaml .Values.resources | nindent 12 }}
      " charts/vgpu/templates/device-plugin/daemonsetnvidia.yaml
  elif [ $os == "Linux" ];then
    sed -i "$((line)) i\\
          resources: {{ toYaml .Values.resources | nindent 12 }}
    " charts/vgpu/templates/device-plugin/daemonsetnvidia.yaml
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

# update chart name vgpu to nvidia-vgpu
if [ $os == "Darwin" ];then
    sed -i "" "s/name: vgpu/name: nvidia-vgpu/g" Chart.yaml
    sed -i "" "s/- name: nvidia-vgpu/- name: vgpu/g" Chart.yaml
elif [ $os == "Linux" ];then
    sed -i "s/name: vgpu/name: nvidia-vgpu/g" Chart.yaml
    sed -i "s/- name: nvidia-vgpu/- name: vgpu/g" Chart.yaml
fi

cat values.yaml