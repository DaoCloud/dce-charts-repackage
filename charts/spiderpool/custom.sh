#!/bin/bash

CHART_DIRECTORY=$1
[ ! -d "$CHART_DIRECTORY" ] && echo "custom shell: error, miss CHART_DIRECTORY $CHART_DIRECTORY " && exit 1

cd $CHART_DIRECTORY
echo "custom shell: CHART_DIRECTORY $CHART_DIRECTORY"
echo "CHART_DIRECTORY $(ls)"

#========================= add your customize bellow ====================
#===============================
echo "inject tls to values.yaml"
TLS_CA="LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURRVENDQWltZ0F3SUJBZ0lVVHN5WmFPenJuTXQxbU02bUxKaFVjNHRYejFZd0RRWUpLb1pJaHZjTkFRRUwKQlFBd01ERXVNQ3dHQTFVRUF3d2xjM0JwWkdWeWNHOXZiQzFqYjI1MGNtOXNiR1Z5TG10MVltVXRjM2x6ZEdWdApMbk4yWXpBZUZ3MHlNakE0TVRnd05ETTFNekphRncwek1qQTRNVFV3TkRNMU16SmFNREF4TGpBc0JnTlZCQU1NCkpYTndhV1JsY25CdmIyd3RZMjl1ZEhKdmJHeGxjaTVyZFdKbExYTjVjM1JsYlM1emRtTXdnZ0VpTUEwR0NTcUcKU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLQW9JQkFRQ2NtcHNIY1RBbjdVMGkrKzVvajdpZTZGYnlWUFdmQzFvKwoyVkM5ZWlSaHpPYUNrWittdm5Qd3NzdDI3c3FSWGNMKzFxaUpja1BndlNTSUNtemVrekp5NERqSzJzYUMyditoCm5iY25EMlUrVDJJM0E2SFBpaDB4NWhrU2ozQVNxRjNHbGpmbHVoU3RadGZpSGdoUFc4eDVkdFZiQzNoMDRabG4KeTUzNllkKzMrZGV0MHU0Z2pTY2hraFo4MTFab2NFRUVhc0tOeC9DaEUyNG0yRS9LaHRidkRmeGhrKzZhZTdpaApHTGg2amtheVh1VHNNeFg3ZE85N3NLOE9aejBFN0NlN1BQTldYU0VORk04ZGRPaDd0NlpTTG5xaWI2a2tOWWV6CldqYXR2d3JLVFFzTnZkNzdhRk53RW9oMklMYnVjczdTVmNUdyt4RDhnUFN6cUZvWTN4VkZBZ01CQUFHalV6QlIKTUIwR0ExVWREZ1FXQkJUc1AyWlJEa2FaM3ZONHhpQXI3eUdvbFNVL0FqQWZCZ05WSFNNRUdEQVdnQlRzUDJaUgpEa2FaM3ZONHhpQXI3eUdvbFNVL0FqQVBCZ05WSFJNQkFmOEVCVEFEQVFIL01BMEdDU3FHU0liM0RRRUJDd1VBCkE0SUJBUUFmSC9ReGM0ako0b1NSUjFMb2dPVHZxOWxqVC9sS2xFdm0rTWQ2NGNiUUNQeE9Pd0ppQ0dxbDZ3Y2QKSzNPUXZmbFZ6NkdGY0NZUE91b2hDdkhBRmhkVWkxZExIbFVBRHpkNUw4RnNmbFJYdExqQVQ2SWhUemJlb0tzQgpHVWVSaGNrNmlORkVaWUp4NEtMSEJQSG0yRzd3U3Bnb0pqbHp5a1d4Zm14RHlRSUh4WG5NNGZjSm1XT2tYajJpCkNXcm9wSUNtVHFIYy9rdnpIK0t4Z3h1YitLTko4UGd4UWhMNzNWVzZpd2RaYmRkVVVwUUNLTDg1TWRxUy9rdXMKT0kwNjNnZjBkY1VNazNvMFV2d1ZUSURUUStJcmwyM3poWlhZY1ZNdkRSOHROMkNRbjVyYXR5ZkxuYXhxZGdtOApiSGJsS2dRU2ZnL25yajE2Q0ROWnNsS0pHcCtCCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K"
TLS_CERT="LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUVEekNDQXZlZ0F3SUJBZ0lVYWQ0V2pHdVFWN1UxUkRWUEh4ZTgxVUd6Z05vd0RRWUpLb1pJaHZjTkFRRUwKQlFBd01ERXVNQ3dHQTFVRUF3d2xjM0JwWkdWeWNHOXZiQzFqYjI1MGNtOXNiR1Z5TG10MVltVXRjM2x6ZEdWdApMbk4yWXpBZUZ3MHlNakE0TVRnd05ETTFNekphRncwek1qQTRNVFV3TkRNMU16SmFNREF4TGpBc0JnTlZCQU1NCkpYTndhV1JsY25CdmIyd3RZMjl1ZEhKdmJHeGxjaTVyZFdKbExYTjVjM1JsYlM1emRtTXdnZ0VpTUEwR0NTcUcKU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLQW9JQkFRQ2NsdHpMYXhva244ZFphZHRMWnlCc2FKS2pUTURxazBQaQp4clZJTHZVKzF1dG5LZlNaVjg5bFI1aitZMGExdWY0Q2hGbWNHK1dxQXRHMi95eHgyUlk5QlU4L0pka1pLdmw3CjV3ZE5QVWNWblRobEZXYStjb3hKdHhMa3pWcFJETFdUR3JrazVQZ3l2TE1DSVlPMEtPbktRT0ZheHlndWdUOWMKVGZXQXdiVU41OTQrZFArMWFQQm9sc0M0WG15Z0lpSGs3Nlc3MXpteXo5cENZYlBmRmxqNTc2a3BYYkFVUWxNQgpsaVJJWWZIUEZ0ZGZmOU5zMG9SQjBlZ0dBY053M0J0d1VNRm9sa0N2YjNSUmFQWGxwWkJSQmZISnZzYVNUT0pGCnN3Q3FLMlUvcXFKcnVLRWNPVnN3aHh2THF1TEhBUGJPQXlhS3BPakQ0d3NJdVE3YWVMa2hBZ01CQUFHamdnRWYKTUlJQkd6QUpCZ05WSFJNRUFqQUFNQXNHQTFVZER3UUVBd0lGNERBZEJnTlZIU1VFRmpBVUJnZ3JCZ0VGQlFjRApBZ1lJS3dZQkJRVUhBd0V3Z2FFR0ExVWRFUVNCbVRDQmxvSVZjM0JwWkdWeWNHOXZiQzFqYjI1MGNtOXNiR1Z5CmdpRnpjR2xrWlhKd2IyOXNMV052Ym5SeWIyeHNaWEl1YTNWaVpTMXplWE4wWlcyQ0pYTndhV1JsY25CdmIyd3QKWTI5dWRISnZiR3hsY2k1cmRXSmxMWE41YzNSbGJTNXpkbU9DTTNOd2FXUmxjbkJ2YjJ3dFkyOXVkSEp2Ykd4bApjaTVyZFdKbExYTjVjM1JsYlM1emRtTXVZMngxYzNSbGNpNXNiMk5oYkRBZEJnTlZIUTRFRmdRVXJzQ201d2hGCjdKY3lkSHZ6djQveDk0T2lVbjR3SHdZRFZSMGpCQmd3Rm9BVTdEOW1VUTVHbWQ3emVNWWdLKzhocUpVbFB3SXcKRFFZSktvWklodmNOQVFFTEJRQURnZ0VCQUpJNkJMOTdxN2dSamNoSHZyYzlpY1ZhUFNOYXVUQlUxSkduUFlxcwpZdm5KMUwrWFM0UWxacFVkWlNqRWd4am9uY1FFS21HRWhEWGNHZGxwYk1CbWoxdVh3bjBNQXVxOXNDSHR0elIyCkdRb1dKOVJJVnFyeTkrbEtBNXpMenUwL2VBS2U3SFRLejNrWS9xL296b0xFNlNxcTh2ZWJhdU5YRThkbW5tZ0YKdkEzNU9KOXRlZ1oraGJsZG1MWEhoeVo3a0FVdEpMcnhmRERuVVNWb2trL1FmcEs0KytOb2NTdExQU1FqUE40RQpKeCttRzRIbnVlcWpEWHkwT3hrYW90d2xMMWMrY1dleDY1Yi9BK2w3WEVYZXgycytocnJLd2FINFMvM0o0dTlsCm1CTEd5aENBTllJZ0JZSnRXMmZPR05qMS9GTkM3bVMwNmdyRVNnSkF5eG1ZbU9NPQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg=="
TLS_KEY="LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tCk1JSUV2Z0lCQURBTkJna3Foa2lHOXcwQkFRRUZBQVNDQktnd2dnU2tBZ0VBQW9JQkFRQ2NsdHpMYXhva244ZFoKYWR0TFp5QnNhSktqVE1EcWswUGl4clZJTHZVKzF1dG5LZlNaVjg5bFI1aitZMGExdWY0Q2hGbWNHK1dxQXRHMgoveXh4MlJZOUJVOC9KZGtaS3ZsNzV3ZE5QVWNWblRobEZXYStjb3hKdHhMa3pWcFJETFdUR3JrazVQZ3l2TE1DCklZTzBLT25LUU9GYXh5Z3VnVDljVGZXQXdiVU41OTQrZFArMWFQQm9sc0M0WG15Z0lpSGs3Nlc3MXpteXo5cEMKWWJQZkZsajU3NmtwWGJBVVFsTUJsaVJJWWZIUEZ0ZGZmOU5zMG9SQjBlZ0dBY053M0J0d1VNRm9sa0N2YjNSUgphUFhscFpCUkJmSEp2c2FTVE9KRnN3Q3FLMlUvcXFKcnVLRWNPVnN3aHh2THF1TEhBUGJPQXlhS3BPakQ0d3NJCnVRN2FlTGtoQWdNQkFBRUNnZ0VBRGU5ekdOQ2dQcVY2Mm9uaGVvcTVSNkhnSXVqcXU0clMzaDlXOUxubWJoV00KVk4yci9KV085SEYwWm5jejkybzZTOE8yMXlpNGFKMDFuVXZhTmJZMGFodkxNS1hQOWVodGZzbW05d2hwWEwxbAplUmJOZlBka0VBOWJLV3plWG5EUXhwV2pQUldrd2tjcGNIQWJ4aHNQVmZEWTNVNUovM3dyR2xqVWJLLzdIK1hnCmpjd3IzZGZGTlZ0bUtvVXVjOVkxejRGUXhpYjEvSmZKeFNXaXd4S1piR0ZwNHpORG0wVTlpL2NscnNnQkxDaUUKNUNuMy94QUJYN0hvWVhvM1VCb1pBdzYweTZkNk8yeW1Zc1cyVlhqVE13NngvOGZyYTBDSWI2RDcyNEtxSDE5WApiRStQMnNaT09uNFdnQ2djc05NcXVTS1ZXTTlqY2JTT1pZZFVYYXJ3ZlFLQmdRRFp6c3I1QVdRUTVTUVozdzRTCnViampvQ3B6Sk5CWHUydlRnY2ZZQ1UyVGlVcnJibktLdFNpNFkwVUs3ZGg1UjBNNXl4azdmcVlsWTBZcFM5UjEKUWdzOUsxYTBOUWlzY1g5ZUh6emdnb2dKU1VVYWkrMWxCckFBSjNYekRJVXFLVWJIalZmSUUxU0FKWUNYYnJESwoxUEkxYk9LV0tXcys2RUtsTGNjYXovL1RPd0tCZ1FDNERBWWhBbDZwYXJIVnhqZzloNUtYYmFUZGhOb2lmcEFCCmo2Z29SQm56dEZIRmFlM0p2aW8wSWlDQ2thTUJDOGlDSlV4cFZEbWJjTVZxM0JETWN5Ty9rUTVkcjQzWThHMTAKUVZyZWU3ZkVvZDM0QWtJaVRXT1NpRmJiRHZHekM4cWFkcG5JNGNOd0tFSlVSbFNVTGtrUXdSOTF5dCtOM1ZMZwp3S3BELy9mblV3S0JnUUROK1JsSlVWOW4rc21oRGFjcFhpalNXZXpLNXMxL3FlWFdKcXp1U0Izc243RVI0MmkrCmM0TUduQm4ycytZN0NvRXdiamgyWXRhTUZNMk0wQUVpd2tvT2xxVnYxWmRXUEI3T3k0dXVaTUp3eGJGcjRWZW0KYWlTV2dMcXlGZXo0YWdCZFJmVDFhQkpJL1M0V0JyOTVrTmRjWHBRSW5US21VczV6bGs3cnREZWhjUUtCZ0VIcgpSSkswRjVXVWVtZDMzSkxsS1BNRnVXUUIvbU1XYzV1cmlXNEtua1QwVThsaVhHSENzN2tDZENSdjV6TXJ0a0F1Ci9jUkgvMjRXSVE5YURNWTlneE5NOEJsTUZJRWI5QWdNbEhCVlhZZVc5anFyREdiZTB3Z2J2d2dzdlJNRTZTY1QKelpidWphSnhPUGlZVEJqYXp4NnFIUXVDZ3psN2lRQ280Uk1EN2hXekFvR0JBTE1WZHRxQStOMzVoeXRBNXorUQpkeHdYelhIVXg0cUJZOHgrdnlHbkp6NHlRTDEvZ1ZNUldqRmN0QmhzOUo0UEZ0b3NhMWRqRzhTSTlqVktHS29QCmVZSExtZloxR25VQ2l6TWxIU01FVCszSVRVYnJjZkl0aDdqdkMwVkl1SXJZRGtrLzF3SElOWnJZL0xxWVR2ckwKTnFTZ09FRGdmbHJPRjlUVWNlanlyOHNxCi0tLS0tRU5EIFBSSVZBVEUgS0VZLS0tLS0K"

sed -i -E 's/tlsCert.*/tlsCert: "'${TLS_CERT}'"/'  values.yaml
sed -i -E 's/tlsCa.*/tlsCa: "'${TLS_CA}'"/'  values.yaml
sed -i -E 's/tlsKey.*/tlsKey: "'${TLS_KEY}'"/'  values.yaml

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

REPLACE_BY_COMMENT  "spiderpoolController.prometheus.serviceMonitor.labels"    "labels:.*"  "${INSIGHT_LABEL}"
REPLACE_BY_COMMENT  "spiderpoolController.prometheus.prometheusRule.labels"    "labels:.*"  "${INSIGHT_LABEL}"
#REPLACE_BY_COMMENT  "spiderpoolController.prometheus.grafanaDashboard.labels"  "labels:.*"  "${INSIGHT_LABEL}"

REPLACE_BY_COMMENT  "spiderpoolAgent.prometheus.serviceMonitor.labels"    "labels:.*"  "${INSIGHT_LABEL}"
REPLACE_BY_COMMENT  "spiderpoolAgent.prometheus.prometheusRule.labels"    "labels:.*"  "${INSIGHT_LABEL}"
#REPLACE_BY_COMMENT  "spiderpoolAgent.prometheus.grafanaDashboard.labels"  "labels:.*"  "${INSIGHT_LABEL}"

REPLACE_BY_COMMENT  "global.imageRegistryOverride"  'imageRegistryOverride:.*'  "imageRegistryOverride: ghcr.m.daocloud.io"

REPLACE_BY_COMMENT  "spiderpoolAgent.prometheus.enabled"  'enabled:.*'  "enabled: true"
REPLACE_BY_COMMENT  "spiderpoolController.prometheus.enabled"  'enabled:.*'  "enabled: true"

REPLACE_BY_COMMENT  "clusterDefaultPool.ipv4Subnet"  'ipv4Subnet:.*'  "ipv4Subnet: \"192.168.0.0/16\""
REPLACE_BY_COMMENT  "clusterDefaultPool.ipv6Subnet"  'ipv6Subnet:.*'  "ipv6Subnet: \"fd00::/112\""
REPLACE_BY_COMMENT  "clusterDefaultPool.ipv4IPRanges"  'ipv4IPRanges:.*'  "ipv4IPRanges: [\"192.168.0.10-192.168.0.100\"]"
REPLACE_BY_COMMENT  "clusterDefaultPool.ipv6IPRanges"  'ipv6IPRanges:.*'  "ipv6IPRanges: [\"fd00::10-fd00::100\"]"

REPLACE_BY_COMMENT  "spiderpoolAgent.debug.logLevel"  'logLevel:.*'  'logLevel: "debug"'
REPLACE_BY_COMMENT  "spiderpoolController.debug.logLevel"  'logLevel:.*'  'logLevel: "debug"'

exit 0


