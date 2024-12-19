#!/usr/bin/env bash

if [ -z "${LOCAL+x}" ]; then
  echo "LOCAL is not defined, skipping..."
  exit 0
fi

bash ./script/upload.sh ./data/metax-gpu-k8s-package.${MX_VERSION}.tar.gz release.daocloud.io dc-image
echo "Upload complete"

rm -rf metax-gpu-extensions/
bash ./script/upload.sh ./data/metax-gpu-k8s-package.${MX_VERSION}.tar.gz release.daocloud.io helm
echo "Extracted helm complete"

if [ "$MX_VERSION" == "0.9.0" ]; then
  yq -i "
    .registry = \"release.daocloud.io/metax\" |
    .gpuLabel.image.name = \"gpu-label\" |
    .gpuLabel.image.version = \"$MX_VERSION\" |
    .topoDiscovery.master.image.name = \"topo-master\" |
    .topoDiscovery.master.image.version = \"$MX_VERSION\" |
    .topoDiscovery.worker.image.name = \"topo-worker\" |
    .topoDiscovery.worker.image.version = \"$MX_VERSION\" |
    .gpuAware.image.name = \"gpu-aware\" |
    .gpuAware.image.version = \"$MX_VERSION\" |
    .gpuDevice.image.name = \"gpu-device\" |
    .gpuDevice.image.version = \"$MX_VERSION\"
  " metax-gpu-extensions/values.yaml
else
  yq -i "
    .registry = \"release.daocloud.io/metax\" |
    .gpuLabel.image.name = \"gpu-label\" |
    .gpuLabel.image.version = \"$MX_VERSION\" |
    .topoMaster.image.name = \"topo-master\" |
    .topoMaster.image.version = \"$MX_VERSION\" |
    .topoWorker.image.name = \"topo-worker\" |
    .topoWorker.image.version = \"$MX_VERSION\" |
    .gpuAware.image.name = \"gpu-aware\" |
    .gpuAware.image.version = \"$MX_VERSION\" |
    .gpuDevice.image.name = \"gpu-device\" |
    .gpuDevice.image.version = \"$MX_VERSION\"
  " metax-gpu-extensions/values.yaml
fi



helm schema-gen metax-gpu-extensions/values.yaml > metax-gpu-extensions/values.schema.json
cp -rf parent/${MX_VERSION}/ metax-gpu-extensions/


echo rm -rf ./metax-gpu-k8s-package.${MX_VERSION}
rm -rf ./metax-gpu-k8s-package.${MX_VERSION}

bash ./script/upload.sh ./data/metax-gpu-k8s-package.${MX_VERSION}.tar.gz release.daocloud.io push-helm
rm -rf metax-gpu-extensions-${MX_VERSION}.tgz
echo "push helm complete"