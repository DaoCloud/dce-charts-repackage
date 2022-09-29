#!/bin/bash

set -x 


CURRENT_DIR_PATH=$(cd $(dirname $0); pwd)

cd $CURRENT_DIR_PATH
mkdir -p f5networks/charts

cd f5networks/charts
rm * -rf

helm repo remove f5-ipam-stable
helm repo add f5-ipam-stable https://f5networks.github.io/f5-ipam-controller/helm-charts/stable
helm pull f5-ipam-stable/f5-ipam-controller --untar

helm repo remove f5-stable
helm repo add f5-stable https://f5networks.github.io/charts/stable
helm pull f5-stable/f5-bigip-ctlr --untar

#================ update 

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

#======================

grep "  namespace: " ./* -Rl   | xargs -n 1 -i sed -i 's?namespace:.*?namespace: {{ .Release.Namespace }}?' {}

