#!/bin/bash

set -x 
set -o errexit
set -o nounset
set -o pipefail


CURRENT_DIR_PATH=$(cd $(dirname $0); pwd)

cd $CURRENT_DIR_PATH

rm -rf f5networks
mkdir -p f5networks/charts
cp -rf parent/.  f5networks/


set -o errexit
set -o nounset

#================== set sub-charts

cd f5networks/charts
rm * -rf

helm repo remove f5-ipam-stable || true
helm repo add f5-ipam-stable https://f5networks.github.io/f5-ipam-controller/helm-charts/stable
helm pull f5-ipam-stable/f5-ipam-controller --untar

helm repo remove f5-stable || true
helm repo add f5-stable https://f5networks.github.io/charts/stable
helm pull f5-stable/f5-bigip-ctlr --untar

# update

FILE="./f5-ipam-controller/templates/f5-ipam-controller-deploy.yaml"

BEGIN_LINE=` grep "securityContext:" $FILE  -n | awk -F':' '{print $1}' `
END_LINE=` grep "containers:" $FILE -n | awk -F':' '{print $1}' `

NUM=`wc -l <<< "$BEGIN_LINE"`
((NUM!=1)) && echo "error, failed to find bengin line" && exit 1
NUM=`wc -l <<< "$END_LINE"`
((NUM!=1)) && echo "error, failed to find end line" && exit 1

ASSERT_LINE=$BEGIN_LINE
BEGIN_LINE=$((BEGIN_LINE+1))
END_LINE=$((END_LINE-1))
echo "delete line $BEGIN_LINE to $END_LINE"
sed -i $BEGIN_LINE,$END_LINE' d' $FILE


sed -i $ASSERT_LINE'  a \        fsGroup: {{ .Values.securityContext.fsGroup }}' $FILE
sed -i $ASSERT_LINE'  a \        runAsGroup: {{ .Values.securityContext.runAsGroup }}' $FILE
sed -i $ASSERT_LINE'  a \        runAsUser: {{ .Values.securityContext.runAsUser }}' $FILE

grep "  namespace: " ./* -Rl   | xargs -n 1 -i sed -i 's?namespace:.*?namespace: {{ .Release.Namespace }}?' {}

echo "update custom resources"
CUSTOM_F5_BIGIP_CPU='10m'
CUSTOM_F5_BIGIP_MEMORY='80Mi'
CUSTOM_F5_IPAM_CPU='3m'
CUSTOM_F5_IPAM_MEMORY='15Mi'

grep "requests_cpu:" ./f5-bigip-ctlr/values.yaml -Rl   | xargs -n 1 -i sed -i "s?# requests_cpu:.*?requests_cpu: $CUSTOM_F5_BIGIP_CPU?" {}
grep "requests_memory:" ./f5-bigip-ctlr/values.yaml -Rl   | xargs -n 1 -i sed -i "s?# requests_memory:.*?requests_memory: $CUSTOM_F5_BIGIP_MEMORY?" {}
grep "requests_cpu:" ./f5-ipam-controller/values.yaml -Rl   | xargs -n 1 -i sed -i "s?# requests_cpu:.*?requests_cpu: $CUSTOM_F5_IPAM_CPU?" {}
grep "requests_memory:" ./f5-ipam-controller/values.yaml -Rl   | xargs -n 1 -i sed -i "s?# requests_memory:.*?requests_memory: $CUSTOM_F5_IPAM_MEMORY?" {}



