CURRENT_FILENAME=$( basename "$0" )
CURRENT_DIR_PATH=$(cd "$CURRENT_FILENAME" || exit; pwd)

KIND_KUBECONFIG=$1

[ -f "$KIND_KUBECONFIG" ] || { echo "error, failed to find kubeconfig $KIND_KUBECONFIG " ; exit 1 ; }

echo "KIND_KUBECONFIG: $KIND_KUBECONFIG"

helm repo update chart-museum  --kubeconfig ${KIND_KUBECONFIG}
# not need wait the redpanda console ready
# it need connect a kafka instance to get ready
HELM_MUST_OPTION="${KIND_KUBECONFIG} "

#==================== add your deploy code bellow =============

set -x

# deploy the redpanda-console
helm install redpanda-console chart-museum/redpanda-console  ${HELM_MUST_OPTION} --namespace default
kubectl get pod --kubeconfig ${KIND_KUBECONFIG} --namespace default

if (($?==0)) ; then
  echo "succeeded to deploy $CHART_DIR"
  exit 0
else
  echo "error, faild to deploy $CHART_DIR"
  exit 1
fi
