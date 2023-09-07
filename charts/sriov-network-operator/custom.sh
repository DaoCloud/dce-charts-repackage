#!/bin/bash

CURRENT_DIR_PATH=$(cd `dirname $0` ; pwd )

echo "custom shell: $CURRENT_DIR_PATH"

#========================= add your customize bellow ====================
#===============================

set -o errexit
set -o pipefail
set -o nounset

if ! which yq &>/dev/null ; then
    echo " 'yq' no found, try to install..."
    YQ_VERSION=v4.30.6
    YQ_BINARY="yq_$(uname | tr 'A-Z' 'a-z')_amd64"
    wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY}.tar.gz -O /tmp/yq.tar.gz &&
     tar -xzf /tmp/yq.tar.gz -C /tmp &&
     mv /tmp/${YQ_BINARY} /usr/bin/yq
fi

if ! which helm-docs &>/dev/null ; then
    echo " 'helm-docs' no found, try to install..."
    wget https://github.com/norwoodj/helm-docs/releases/download/v1.11.0/helm-docs_1.11.0_Linux_x86_64.tar.gz -O /tmp/helm-docs_1.11.0_Linux_x86_64.tar.gz &&
     tar -xzf /tmp/helm-docs_1.11.0_Linux_x86_64.tar.gz -C /tmp &&
     mv /tmp/helm-docs /usr/local/bin/helm-docs
fi

GIT_REPO=https://github.com/k8snetworkplumbingwg/sriov-network-operator.git
CHART_NAME=sriov-network-operator

rm -rf /tmp/${CHART_NAME} || true
git -C /tmp clone ${GIT_REPO}
cp -rf /tmp/${CHART_NAME}/deployment/$CHART_NAME $CURRENT_DIR_PATH
cd /tmp/${CHART_NAME}
export SRIOV_NETWORK_OPERATOR_CURRENT_COMMIT_TIME=$(git show -s --format='format:%cI')
export SRIOV_NETWORK_OPERATOR_CURRENT_COMMIT_HASH=$(git show -s --format='format:%H')
export SRIOV_NETWORK_OPERATOR_CURRENT_CHART_TIME=$(date "+%Y-%m-%dT%H:%M:%S")
cd -

echo "SRIOV_NETWORK_OPERATOR_CURRENT_CHART_TIME: ${SRIOV_NETWORK_OPERATOR_CURRENT_CHART_TIME}"
echo "SRIOV_NETWORK_OPERATOR_CURRENT_COMMIT_TIME: ${SRIOV_NETWORK_OPERATOR_CURRENT_COMMIT_TIME}"
echo "SRIOV_NETWORK_OPERATOR_CURRENT_COMMIT_HASH: ${SRIOV_NETWORK_OPERATOR_CURRENT_COMMIT_HASH}"

L=$(cat $CURRENT_DIR_PATH/$CHART_NAME/values.yaml | grep -n "images:" | awk -F ':' '{print $1}')
[ -z "$L" ] &&  echo "can't found LINE in values.yaml" && exit 1
sed ''$((L+1))',$d' $CURRENT_DIR_PATH/${CHART_NAME}/values.yaml > $CURRENT_DIR_PATH/${CHART_NAME}/values.yaml.tmp

yq -i '
   .images.registry="ghcr.m.daocloud.io" |
   .images.operator.repository="k8snetworkplumbingwg/sriov-network-operator" |
   .images.operator.tag="v1.2.0" |
   .images.sriovConfigDaemon.repository="k8snetworkplumbingwg/sriov-network-operator-config-daemon" |
   .images.sriovConfigDaemon.tag="v1.2.0" |
   .images.sriovCni.repository="k8snetworkplumbingwg/sriov-cni" |
   .images.sriovCni.tag="v2.7.0" |
   .images.ibSriovCni.repository="k8snetworkplumbingwg/ib-sriov-cni" |
   .images.ibSriovCni.tag="v1.0.2" |
   .images.sriovDevicePlugin.repository="k8snetworkplumbingwg/sriov-network-device-plugin" |
   .images.sriovDevicePlugin.tag="v3.5.1" |
   .images.resourcesInjector.repository="k8snetworkplumbingwg/network-resources-injector" |
   .images.resourcesInjector.tag="v1.5" |
   .images.webhook.repository="k8snetworkplumbingwg/sriov-network-operator-webhook" |
   .images.webhook.tag="v1.2.0" |
   .operator.resourcePrefix="spidernet.io" |
   .sriovNetworkNodePolicy.name="default-nodepolicy" |
   .sriovNetworkNodePolicy.resourceName="sriov_netdevice" |
   .sriovNetworkNodePolicy.numVfs=0 |
   .sriovNetworkNodePolicy.pfNames=[] |
   .sriovNetworkNodePolicy.nodeSelector.labelKey="node-role.kubernetes.io/worker" |
   .sriovNetworkNodePolicy.nodeSelector.labelValue=""
' $CURRENT_DIR_PATH/${CHART_NAME}/values.yaml.tmp

mv $CURRENT_DIR_PATH/${CHART_NAME}/values.yaml.tmp $CURRENT_DIR_PATH/${CHART_NAME}/values.yaml

# change origin chart template:
OPERATOR_TEMPLATE_PATH=$CURRENT_DIR_PATH/$CHART_NAME/templates/operator.yaml
if [ ! -f "${OPERATOR_TEMPLATE_PATH}" ] ; then
  echo "$OPERATOR_TEMPLATE_PATHOPERATOR_TEMPLATE_PATH can't find, exit 2" && exit 2
fi

if [ "$(uname)" == "Darwin" ];then
  gsed -i '/memory: 100Mi/a\            limits:\n              cpu: 300m\n              memory: 300Mi'   $OPERATOR_TEMPLATE_PATH
  sed -i '' 's?openshift.io?spidernet.io?' $CURRENT_DIR_PATH/$CHART_NAME/README.md
  sed  -i '' 's?{{ .Values.images.operator }}?{{ .Values.images.registry }}/{{ .Values.images.operator.repository }}:{{ .Values.images.operator.tag }}?'   $OPERATOR_TEMPLATE_PATH
  sed  -i '' 's?{{ .Values.images.sriovCni }}?{{ .Values.images.registry }}/{{ .Values.images.sriovCni.repository }}:{{ .Values.images.sriovCni.tag }}?'   $OPERATOR_TEMPLATE_PATH
  sed  -i '' 's?{{ .Values.images.ibSriovCni }}?{{ .Values.images.registry }}/{{ .Values.images.ibSriovCni.repository }}:{{ .Values.images.ibSriovCni.tag }}?'   $OPERATOR_TEMPLATE_PATH
  sed  -i '' 's?{{ .Values.images.sriovDevicePlugin }}?{{ .Values.images.registry }}/{{ .Values.images.sriovDevicePlugin.repository }}:{{ .Values.images.sriovDevicePlugin.tag }}?'   $OPERATOR_TEMPLATE_PATH
  sed  -i '' 's?{{ .Values.images.resourcesInjector }}?{{ .Values.images.registry }}/{{ .Values.images.resourcesInjector.repository }}:{{ .Values.images.resourcesInjector.tag }}?'   $OPERATOR_TEMPLATE_PATH
  sed  -i '' 's?{{ .Values.images.sriovConfigDaemon }}?{{ .Values.images.registry }}/{{ .Values.images.sriovConfigDaemon.repository }}:{{ .Values.images.sriovConfigDaemon.tag }}?'   $OPERATOR_TEMPLATE_PATH
  sed  -i '' 's?{{ .Values.images.webhook }}?{{ .Values.images.registry }}/{{ .Values.images.webhook.repository }}:{{ .Values.images.webhook.tag }}?'   $OPERATOR_TEMPLATE_PATH
else
  sed  -i '/memory: 100Mi/a\            limits:\n              cpu: 300m\n              memory: 300Mi'   $OPERATOR_TEMPLATE_PATH
  sed  -i  's?openshift.io?spidernet.io?' $CURRENT_DIR_PATH/$CHART_NAME/README.md
  sed  -i  's?{{ .Values.images.operator }}?{{ .Values.images.registry }}/{{ .Values.images.operator.repository }}:{{ .Values.images.operator.tag }}?'   $OPERATOR_TEMPLATE_PATH
  sed  -i  's?{{ .Values.images.sriovCni }}?{{ .Values.images.registry }}/{{ .Values.images.sriovCni.repository }}:{{ .Values.images.sriovCni.tag }}?'   $OPERATOR_TEMPLATE_PATH
  sed  -i  's?{{ .Values.images.ibSriovCni }}?{{ .Values.images.registry }}/{{ .Values.images.ibSriovCni.repository }}:{{ .Values.images.ibSriovCni.tag }}?'   $OPERATOR_TEMPLATE_PATH
  sed  -i  's?{{ .Values.images.sriovDevicePlugin }}?{{ .Values.images.registry }}/{{ .Values.images.sriovDevicePlugin.repository }}:{{ .Values.images.sriovDevicePlugin.tag }}?'   $OPERATOR_TEMPLATE_PATH
  sed  -i  's?{{ .Values.images.resourcesInjector }}?{{ .Values.images.registry }}/{{ .Values.images.resourcesInjector.repository }}:{{ .Values.images.resourcesInjector.tag }}?'   $OPERATOR_TEMPLATE_PATH
  sed  -i  's?{{ .Values.images.sriovConfigDaemon }}?{{ .Values.images.registry }}/{{ .Values.images.sriovConfigDaemon.repository }}:{{ .Values.images.sriovConfigDaemon.tag }}?'   $OPERATOR_TEMPLATE_PATH
  sed  -i  's?{{ .Values.images.webhook }}?{{ .Values.images.registry }}/{{ .Values.images.webhook.repository }}:{{ .Values.images.webhook.tag }}?'   $OPERATOR_TEMPLATE_PATH
fi

# Version
export NEW_CHART_VERSION=1.2.0
yq -i '
   .version=strenv(NEW_CHART_VERSION) |
   .appVersion=strenv(NEW_CHART_VERSION) |
   .keywords[1]="networking"
' $CURRENT_DIR_PATH/$CHART_NAME/Chart.yaml

# README.md
LINE=$(cat $CURRENT_DIR_PATH/$CHART_NAME/README.md | grep -n "### Images parameters" | awk -F ':' '{print $1}')
[ -z "$LINE" ] && echo "failed to find LINE" && exit 1

sed ''$((LINE+1))',$d' $CURRENT_DIR_PATH/$CHART_NAME/README.md > $CURRENT_DIR_PATH/$CHART_NAME/README.md.tmp
echo '
| Name | description | default |
| ---- | ----------- | ------- |
| `images.operator.registry` | sriov-network-operator global image registry | ghcr.m.daocloud.io |
| `images.operator.repository` | Operator controller image repository | k8snetworkplumbingwg/sriov-network-operator |
| `images.operator.tag` | Operator controller image tag | latest |
| `images.sriovConfigDaemon.repository` | Daemon node agent image repository | k8snetworkplumbingwg/sriov-network-operator-config-daemon |
| `images.sriovConfigDaemon.tag` | Daemon node agent image tag | latest |
| `images.sriovCni.repository` | SR-IOV CNI image repository | k8snetworkplumbingwg/sriov-cni |
| `images.sriovCni.tag` | SR-IOV CNI image tag | latest |
| `images.ibSriovCni.repository` | InfiniBand SR-IOV CNI image repository | k8snetworkplumbingwg/ib-sriov-cni |
| `images.ibSriovCni.tag` | InfiniBand SR-IOV CNI image tag | latest |
| `images.sriovDevicePlugin.repository` | SR-IOV device plugin image repository | k8snetworkplumbingwg/sriov-network-device-plugin |
| `images.sriovDevicePlugin.tag` | SR-IOV device plugin image tag | latest |
| `images.resourcesInjector.repository` | Resources Injector image repository | k8snetworkplumbingwg/network-resources-injector |
| `images.resourcesInjector.tag` | Resources Injector image tag | latest |
| `images.webhook.repository` | Operator Webhook image repository | k8snetworkplumbingwg/sriov-network-operator-webhook |
| `images.webhook.tag` | Operator Webhook image tag | latest |
| `sriovNetworkNodePolicy.name` | default sriovNetworkNodePolicy CRD instance name | default-nodepolicy |
| `sriovNetworkNodePolicy.resourceName` | sriov device plugin resourceName | sriov_netdevice |
| `sriovNetworkNodePolicy.pfNames` | sriov device plugin PF name, Must be a NIC present on the node and capable of SR-IVO feature | "" |
| `sriovNetworkNodePolicy.numVfs` | number of sriov device plugin VFs | 0 |
| `sriovNetworkNodePolicy.nodeSelector.labelKey` | the label key of nodes that support the SR-IOV feature | "node-role.kubernetes.io/worker" |
| `sriovNetworkNodePolicy.nodeSelector.labelValue` | the label value of nodes that support the SR-IOV feature | "" |' >> $CURRENT_DIR_PATH/$CHART_NAME/README.md.tmp

#printf "
#### Chart Version Information
#
#- **_CHART_BUILT_TIME_**: %s
#
#- **_GIT_COMMIT_HASH_**: %s
#
#- **_GIT_COMMIT_TIME_**: %s
#" "$SRIOV_NETWORK_OPERATOR_CURRENT_CHART_TIME" "$SRIOV_NETWORK_OPERATOR_CURRENT_COMMIT_HASH" "$SRIOV_NETWORK_OPERATOR_CURRENT_COMMIT_TIME" >> $CURRENT_DIR_PATH/$CHART_NAME/README.md.tmp

mv $CURRENT_DIR_PATH/$CHART_NAME/README.md.tmp $CURRENT_DIR_PATH/$CHART_NAME/README.md

cat $CURRENT_DIR_PATH/parent/default-sriovnetworknodepolicy.yaml >> $CURRENT_DIR_PATH/$CHART_NAME/templates/sriovnetworknodepolicy.yaml

cp -f $CURRENT_DIR_PATH/parent/.relok8s-images.yaml $CURRENT_DIR_PATH/$CHART_NAME
cp -f $CURRENT_DIR_PATH/parent/values.schema.json $CURRENT_DIR_PATH/$CHART_NAME/

exit 0


