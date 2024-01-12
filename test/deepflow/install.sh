CURRENT_FILENAME=$( basename "$0" )
CURRENT_DIR_PATH=$(cd "$CURRENT_FILENAME" || exit; pwd)

KIND_KUBECONFIG=$1

[ -f "$KIND_KUBECONFIG" ] || { echo "error, failed to find kubeconfig $KIND_KUBECONFIG " ; exit 1 ; }

echo "KIND_KUBECONFIG: $KIND_KUBECONFIG"

helm repo update chart-museum  --kubeconfig ${KIND_KUBECONFIG}
# mysql always crash in kind environment due to unknown reason and it has already been tested on other environments, ignore --wait option.
HELM_MUST_OPTION=" --timeout 10m0s --kubeconfig ${KIND_KUBECONFIG} "

#==================== add your deploy code bellow =============

set -x

helm install deepflow chart-museum/deepflow  ${HELM_MUST_OPTION} --namespace deepflow --create-namespace --set global.ghippoProxy.enabled=false

if (($?==0)) ; then
  echo "succeeded to deploy $CHART_DIR"
  kubectl get pod -n deepflow --kubeconfig ${KIND_KUBECONFIG} -o=jsonpath='{range .items[*]}{.metadata.name}{"\t"}{range .spec.containers[*]}{.image}{"  "}{end}{"\n"}{end}'
  exit 0
else
  echo "error, faild to deploy $CHART_DIR"
  exit 1
fi
