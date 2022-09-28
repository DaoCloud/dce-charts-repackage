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

#==============================
echo "insert insight label"
INSIGHT_LABEL="labels: { \"operator.insight.io/managed-by\": \"insight\" }"

REPLACE_BY_COMMENT(){
  COMMENT="$1"
  OLD_DATA="$2"
  NEW_DATA="$3"

  LINE=`cat values.yaml | grep -n "$COMMENT"  | awk -F: '{print $1}' `
  [ -z "$LINE" ] && echo "failed to find comment $COMMENT" && exit 1
  sed -i -E ''$((LINE+1))' s?'"${OLD_DATA}"'?'"${NEW_DATA}"'?' values.yaml
  (($?!=0)) && echo  echo "failed to sed " && exit 2
  return 0
}

REPLACE_BY_COMMENT  " spiderpoolController.prometheus.serviceMonitor.labels "    "labels:.*"  "${INSIGHT_LABEL}"
REPLACE_BY_COMMENT  " spiderpoolController.prometheus.prometheusRule.labels "    "labels:.*"  "${INSIGHT_LABEL}"
#REPLACE_BY_COMMENT  "spiderpoolController.prometheus.grafanaDashboard.labels "  "labels:.*"  "${INSIGHT_LABEL}"

REPLACE_BY_COMMENT  " spiderpoolAgent.prometheus.serviceMonitor.labels "    "labels:.*"  "${INSIGHT_LABEL}"
REPLACE_BY_COMMENT  " spiderpoolAgent.prometheus.prometheusRule.labels "    "labels:.*"  "${INSIGHT_LABEL}"
#REPLACE_BY_COMMENT  " spiderpoolAgent.prometheus.grafanaDashboard.labels "  "labels:.*"  "${INSIGHT_LABEL}"

REPLACE_BY_COMMENT  " global.imageRegistryOverride "  'imageRegistryOverride:.*'  "imageRegistryOverride: ghcr.m.daocloud.io"

REPLACE_BY_COMMENT  " spiderpoolAgent.prometheus.enabled "  'enabled:.*'  "enabled: true"
REPLACE_BY_COMMENT  " spiderpoolController.prometheus.enabled "  'enabled:.*'  "enabled: true"

REPLACE_BY_COMMENT  " feature.enableSpiderSubnet "  'enableSpiderSubnet:.*'  "enableSpiderSubnet: true"

REPLACE_BY_COMMENT  " feature.enableIPv4 "  'enableIPv4:.*'  "enableIPv4: true"
REPLACE_BY_COMMENT  " feature.enableIPv6 "  'enableIPv6:.*'  "enableIPv6: false"

REPLACE_BY_COMMENT  " clusterDefaultPool.installIPv4IPPool "  'installIPv4IPPool:.*'  "installIPv4IPPool: true"
REPLACE_BY_COMMENT  " clusterDefaultPool.installIPv6IPPool "  'installIPv6IPPool:.*'  "installIPv6IPPool: false"

REPLACE_BY_COMMENT  " clusterDefaultPool.ipv4Subnet "  'ipv4Subnet:.*'  "ipv4Subnet: \"192.168.0.0/16\""
REPLACE_BY_COMMENT  " clusterDefaultPool.ipv6Subnet "  'ipv6Subnet:.*'  "ipv6Subnet: \"fd00::/112\""
REPLACE_BY_COMMENT  " clusterDefaultPool.ipv4Gateway " 'ipv4Gateway:.*'  "ipv4Gateway: \"192.168.0.1\""
REPLACE_BY_COMMENT  " clusterDefaultPool.ipv6Gateway " 'ipv6Gateway:.*'  "ipv6Gateway: \"fd00::1\""
REPLACE_BY_COMMENT  " clusterDefaultPool.ipv4IPRanges "  'ipv4IPRanges:.*'  "ipv4IPRanges: [\"192.168.0.10-192.168.0.100\"]"
REPLACE_BY_COMMENT  " clusterDefaultPool.ipv6IPRanges "  'ipv6IPRanges:.*'  "ipv6IPRanges: [\"fd00::10-fd00::100\"]"

REPLACE_BY_COMMENT  " spiderpoolAgent.debug.logLevel "  'logLevel:.*'  'logLevel: "debug"'
REPLACE_BY_COMMENT  " spiderpoolController.debug.logLevel "  'logLevel:.*'  'logLevel: "debug"'

exit 0


