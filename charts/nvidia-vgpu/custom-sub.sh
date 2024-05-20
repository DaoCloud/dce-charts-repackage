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

echo "custom-sub.sh"

# sed resourceName: "nvidia.com/gpu" to resourceName: "nvidia.com/vgpu"
if [ $os == "Darwin" ];then
    sed -i "" "s/resourceName: \"nvidia.com\/gpu\"/resourceName: \"nvidia.com\/vgpu\"/g" charts/hami/values.yaml
elif [ $os == "Linux" ];then
    sed -i "s/resourceName: \"nvidia.com\/gpu\"/resourceName: \"nvidia.com\/vgpu\"/g" charts/hami/values.yaml
fi


# sed scheduler.kubeScheduler.registry and scheduler.kubeScheduler.repository
line=`sed -n -e '/image: registry.cn-hangzhou/=' charts/hami/values.yaml`
if [ $os == "Darwin" ];then
     sed -i "" "$line"d charts/hami/values.yaml
     sed -i "" "$line i\\
    registry: k8s-gcr.m.daocloud.io
      " charts/hami/values.yaml
     sed -i "" "$((line+1)) i\\
    repository: kube-scheduler
      " charts/hami/values.yaml
elif [ $os == "Linux" ];then
     sed -i "$line"d charts/hami/values.yaml
     sed -i "$line i\\
    registry: k8s-gcr.m.daocloud.io
           " charts/hami/values.yaml
     sed -i "$((line+1)) i\\
    repository: kube-scheduler
           " charts/hami/values.yaml
fi

# set scheduler imageTag v1.20.0 to "v1.24.0"
if [ $os == "Darwin" ];then
        sed -i "" "s/imageTag: \"v1.20.0\"/imageTag: \"v1.24.0\"/g" charts/hami/values.yaml
elif [ $os == "Linux" ];then
        sed -i "s/imageTag: \"v1.20.0\"/imageTag: \"v1.24.0\"/g" charts/hami/values.yaml
fi

# sed scheduler.extender.image
line=$(sed -n -e '/ image: "projecthami\/hami"/=' charts/hami/values.yaml  | head -n 1)
if [ $os == "Darwin" ];then
     sed -i "" "$line"d charts/hami/values.yaml
     sed -i "" "$line i\\
    registry: docker.m.daocloud.io
          " charts/hami/values.yaml
     sed -i "" "$((line+1)) i\\
    repository: projecthami/hami
           " charts/hami/values.yaml
elif [ $os == "Linux" ];then
    sed -i "$line"d charts/hami/values.yaml
    sed -i  "$line i\\
    registry: docker.m.daocloud.io
            " charts/hami/values.yaml
    sed -i  "$((line+1)) i\\
    repository: projecthami/hami
            " charts/hami/values.yaml
fi

line=$(sed -n -e '/ image: "projecthami\/hami"/=' charts/hami/values.yaml  | head -n 1)
if [ $os == "Darwin" ];then
     sed -i "" "$line"d charts/hami/values.yaml
     sed -i "" "$line i\\
  registry: docker.m.daocloud.io
          " charts/hami/values.yaml
     sed -i "" "$((line+1)) i\\
  repository: projecthami/hami
           " charts/hami/values.yaml
elif [ $os == "Linux" ];then
    sed -i "$line"d charts/hami/values.yaml
    sed -i  "$line i\\
  registry: docker.m.daocloud.io
            " charts/hami/values.yaml
    sed -i  "$((line+1)) i\\
  repository: projecthami/hami
            " charts/hami/values.yaml
fi
# sed patch image
line=$(sed -n -e '/ image: docker.io\/jettech\/kube-webhook-certgen/=' charts/hami/values.yaml  | head -n 1)
if [ $os == "Darwin" ];then
     sed -i "" "$line"d charts/hami/values.yaml
     sed -i "" "$line i\\
    registry: docker.m.daocloud.io
          " charts/hami/values.yaml
     sed -i "" "$((line+1)) i\\
    repository: jettech/kube-webhook-certgen
           " charts/hami/values.yaml
     sed -i "" "$((line+2)) i\\
    tag: v1.5.2
          " charts/hami/values.yaml
elif [ $os == "Linux" ];then
    sed -i "$line"d charts/hami/values.yaml
    sed -i  "$line i\\
    registry: docker.m.daocloud.io
            " charts/hami/values.yaml
    sed -i  "$((line+1)) i\\
    repository: jettech/kube-webhook-certgen
            " charts/hami/values.yaml
    sed -i "$((line+2)) i\\
    tag: v1.5.2
              " charts/hami/values.yaml
fi

# sed patch imageNew
line=$(sed -n -e '/ imageNew: liangjw\/kube-webhook-certgen/=' charts/hami/values.yaml  | head -n 1)
if [ $os == "Darwin" ];then
    sed -i "" "$line"d charts/hami/values.yaml
     sed -i "" "$((line)) i\\
    newRepository: liangjw/kube-webhook-certgen
           " charts/hami/values.yaml
     sed -i "" "$((line+1)) i\\
    newTag: v1.1.1
          " charts/hami/values.yaml
elif [ $os == "Linux" ];then
     sed -i "$line"d charts/hami/values.yaml
     sed -i  "$((line)) i\\
    newRepository: liangjw/kube-webhook-certgen
           " charts/hami/values.yaml
     sed -i  "$((line+1)) i\\
    newTag: v1.1.1
          " charts/hami/values.yaml
fi

# add resources config key
cat >> charts/hami/values.yaml << EOL
resources:
  limits:
    cpu: 500m
    memory: 720Mi
  requests:
    cpu: 100m
    memory: 128Mi
EOL
