include ../Makefile.defs

PROJECT ?=
KIND_CLUSTER_NAME ?= network-chart
KIND_KUBECONFIG := $(ROOT_DIR)/test/.config

DANGEROUS_MULTUS := multus-underlay
.PHONY: all
all: e2e

.PHONY: e2e
e2e:
	#setup global kind
	make init-kind -e KIND_CONFIG_PATH=./yaml/kind.yaml || { echo "error, failed to setup kind " ; exit 1 ; }
	PROJECT_LIST="$(PROJECT)" ; [ -n "$${PROJECT_LIST}" ] || PROJECT_LIST=` ls ` ; \
		RUN_DANGEROUS_ITEM=false ; \
		for ITEM in $$PROJECT_LIST ; do \
		    [ -d "$${ITEM}" ] || continue ; \
			if [ "$${ITEM}" == "$(DANGEROUS_MULTUS)" ] ; then  \
					RUN_DANGEROUS_ITEM=true ; \
					continue ; \
			fi ; \
			KIND_CONFIG_PATH=$(ROOT_DIR)/test/$${ITEM}/kind.yaml ;\
			INSTALL_PATH=$(ROOT_DIR)/test/$${ITEM}/install.sh ;\
			if [ -n "$(PROJECT)" ]; then \
			    [ -f "$${INSTALL_PATH}" ] || { echo "error, miss $${INSTALL_PATH}" ; exit 1 ; } ; \
		  	else \
			    [ ! -f "$${INSTALL_PATH}" ] && continue ; \
            fi ; \
            echo "============ run e2e for project $${ITEM} ===================="; \
            if [ -f "$${KIND_CONFIG_PATH}" ] ; then  \
            	echo "the project $${ITEM}  needs a standby kind cluster" ; \
				make init-kind -e KIND_CONFIG_PATH=$${CONFIG_PATH} || { echo "error, failed to setup kind for $${ITEM}"; exit 1 ;} ; \
            fi ; \
			echo "sync project $${ITEM}"; \
			make sync -e PROJECT=$${ITEM} || { echo "error, failed to sync $${ITEM}" ; exit 1 ; } ; \
			echo "deploy project $${ITEM}"; \
			make deploy -e INSTALL_PATH=$${INSTALL_PATH}  -e PROJECT=$${ITEM} || { echo "error, failed to deploy $${ITEM}" ; exit 1 ; } ; \
	  	done ; \
	  	if [ "$${RUN_DANGEROUS_ITEM}" == "true" ] ; then \
	  			PROJECT_LIST=" $(DANGEROUS_MULTUS) "  ; \
				for ITEM in $$PROJECT_LIST ; do \
					[ -d "$${ITEM}" ] || continue ; \
					KIND_CONFIG_PATH=$(ROOT_DIR)/test/$${ITEM}/kind.yaml ;\
					INSTALL_PATH=$(ROOT_DIR)/test/$${ITEM}/install.sh ;\
					if [ -n "$(PROJECT)" ]; then \
						[ -f "$${INSTALL_PATH}" ] || { echo "error, miss $${INSTALL_PATH}" ; exit 1 ; } ; \
					else \
						[ ! -f "$${INSTALL_PATH}" ] && continue ; \
					fi ; \
					echo "============ run e2e for project $${ITEM} ===================="; \
					if [ -f "$${KIND_CONFIG_PATH}" ] ; then  \
						echo "the project $${ITEM}  needs a standby kind cluster" ; \
						make init-kind -e KIND_CONFIG_PATH=$${CONFIG_PATH} || { echo "error, failed to setup kind for $${ITEM}"; exit 1 ;} ; \
					fi ; \
					echo "sync project $${ITEM}"; \
					make sync -e PROJECT=$${ITEM} || { echo "error, failed to sync $${ITEM}" ; exit 1 ; } ; \
					echo "deploy project $${ITEM}"; \
					make deploy -e INSTALL_PATH=$${INSTALL_PATH}  -e PROJECT=$${ITEM} || { echo "error, failed to deploy $${ITEM}" ; exit 1 ; } ; \
				done ; \
  	    fi ;\
	  	exit 0


.PHONY: init-kind
init-kind: KIND_CONFIG_PATH ?=
init-kind: checkBin clean
	[ -f $(KIND_CONFIG_PATH) ] || { echo "error, miss file KIND_CONFIG_PATH=$(KIND_CONFIG_PATH)" ; exit 1 ; }
	- sysctl -w net.ipv6.conf.all.disable_ipv6=0 || true
	- sysctl -w fs.inotify.max_user_watches=524288 || true
	- sysctl -w fs.inotify.max_user_instances=8192  || true
	kind create cluster --name  $(KIND_CLUSTER_NAME) --config $(KIND_CONFIG_PATH)  --kubeconfig $(KIND_KUBECONFIG) --image kindest/node:v1.25.0
	- kubectl --kubeconfig $(KIND_KUBECONFIG) taint nodes --all node-role.kubernetes.io/master- || true
	- kubectl --kubeconfig $(KIND_KUBECONFIG) taint nodes --all node-role.kubernetes.io/control-plane- || true
	@echo "===================== deploy prometheus CRD ========== "
	{ timeout 10 kubectl apply --kubeconfig $(KIND_KUBECONFIG) -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml ; } \
		|| kubectl apply --kubeconfig $(KIND_KUBECONFIG)  -f ./yaml/monitoring.coreos.com_servicemonitors.yaml
	{ timeout 10 kubectl apply --timeout 10s --kubeconfig $(KIND_KUBECONFIG) -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml ; } \
		|| kubectl apply --kubeconfig $(KIND_KUBECONFIG) -f ./yaml/monitoring.coreos.com_podmonitors.yaml
	{ timeout 10 kubectl apply --timeout 10s --kubeconfig $(KIND_KUBECONFIG) -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml ; } \
		|| kubectl apply --kubeconfig $(KIND_KUBECONFIG) -f ./yaml/monitoring.coreos.com_prometheusrules.yaml
	{ timeout 10 kubectl apply --timeout 10s --kubeconfig $(KIND_KUBECONFIG) -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml  ; } \
		|| kubectl apply --kubeconfig $(KIND_KUBECONFIG) -f ./yaml/monitoring.coreos.com_probes.yaml
	{ timeout 10 kubectl apply --timeout 10s --kubeconfig $(KIND_KUBECONFIG) -f https://raw.githubusercontent.com/grafana-operator/grafana-operator/master/deploy/manifests/latest/crds.yaml  ; } \
		|| kubectl apply --kubeconfig $(KIND_KUBECONFIG) -f ./yaml/grafanadashboards.yaml
	echo "show kubernetes node image " && docker ps
	@echo "========================================================"
	@echo "   deploy kind cluster $(KIND_CLUSTER_NAME)             "
	@echo "  kubectl get node --kubeconfig $(KIND_KUBECONFIG)      "
	@echo "========================================================"
	echo "install registry and chart museum"
	helm repo add twuni https://helm.twun.io --force-update  --kubeconfig $(KIND_KUBECONFIG) || { echo "error, failed to add registry repo"; exit 1 ; }
	helm upgrade --debug --install --create-namespace --cleanup-on-fail --namespace registry-system  --set nodeSelector."kubernetes\\.io/hostname=network-chart-worker" --set service.type=NodePort  --set service.nodePort=30080  registry twuni/docker-registry --wait --version  2.2.2 --kubeconfig $(KIND_KUBECONFIG) || \
	{ echo "error, failed to deploy registry"; exit 1 ; }
	helm repo add chartmuseum https://chartmuseum.github.io/charts --kubeconfig $(KIND_KUBECONFIG) || { echo "error, failed to add chartmuseum repo"; exit 1 ; }
	helm upgrade --debug --install --create-namespace --cleanup-on-fail --namespace chartmuseum-system --set nodeSelector."kubernetes\\.io/hostname=network-chart-worker" --set service.type=NodePort  --set service.nodePort=30081 --set env.open.DISABLE_API=false  chartmuseum chartmuseum/chartmuseum --wait --version 3.9.2 --kubeconfig $(KIND_KUBECONFIG) || \
	{ echo "error, failed to deploy chartmuseum"; exit 1 ; }
	helm repo add chart-museum  http://127.0.0.1:30081 --force-update --kubeconfig $(KIND_KUBECONFIG) || { echo "error, failed to add charts repo"; exit 1 ; }

.PHONY: sync
sync: PROJECT=
sync: checkBin
	source $(ROOT_DIR)/charts/$(PROJECT)/config ; [ "${NO_IMAGE}" != "true" ] || { echo "ingore sync $(PROJECT) charts and images to local registry" ; exit 0 ; }
	@ echo "sync $(PROJECT) charts and images to local registry"
	CHART_PATH=$(ROOT_DIR)/charts/$(PROJECT) ; \
	VERSION=`sed -n  '/VERSION/p' $${CHART_PATH}/config|awk -F = '{print $$2}'` || { echo "error, failed to get charts version" ; exit 1 ; } ;\
	mkdir -p _tmp && DIR=_tmp ;\
    relok8s chart move $${CHART_PATH}/$(PROJECT) --to-intermediate-bundle $${DIR}/$(PROJECT)_$${VERSION}.bundle.tar -y || { echo "error, failed to save charts and images to local" ; exit 1 ; } ; \
    CONFIG=" \
source:  \n \
     intermediateBundlesPath: ${ROOT_DIR}/test/$${DIR} \n \
target:  \n \
     containerRegistry: 127.0.0.1:30080 \n \
     repo:  \n \
         kind: CHARTMUSEUM \n \
         url: http://127.0.0.1:30081"; \
     echo -e "$${CONFIG}" > $${DIR}/config.yaml ; \
     charts-syncer sync --config $${DIR}/config.yaml --insecure true || { echo "error, failed to sync charts and images to local registry" ; exit 1 ; } ; \
	 make checkImages -e PROJECT=$${PROJECT} || { echo "error, failed to check $${PROJECT} images registry" ; exit 1 ; } ; \
     rm -rf $${DIR} ;

.PHONY: checkImages
checkImages: PROJECT=
checkImages: checkBin
	@ echo "check $(PROJECT) images registry"
	helm repo update chart-museum  --kubeconfig $(KIND_KUBECONFIG) || { echo "error, failed to update helm chart-museum repo " ; exit 1 ; } ; \
    IMAGE_LIST=` helm template test chart-museum/$${PROJECT}  | grep " image: " | tr -d '"'| awk '{print $$2}' ` ;\
	if [ -z "$${IMAGE_LIST}" ] ; then \
		echo "error, failed to find image from chart template for $(PROJECT)" ; exit 1 ; \
	else \
		echo "found image from $(PROJECT) chart template: $${IMAGE_LIST} " ; \
		for IMAGE in $${IMAGE_LIST} ; do \
		    if [[ $${IMAGE} != 127.0.0.1:30080* ]] ; then \
			    echo "error, failed to check image $${IMAGE} from chart template for $(PROJECT)" ; exit 1 ; \
		    fi ; \
		done ; \
	fi ; \

.PHONY: deploy
deploy: INSTALL_PATH=
deploy: PROJECT=
deploy: TRY_LOAD_LOCAL_IMAGE ?= false
deploy: checkBin
	@ echo "helm install for $(PROJECT) with $(INSTALL_PATH)"
	@ [ -f "$(INSTALL_PATH)" ] || { echo "error, failed to find INSTALL_PATH $(INSTALL_PATH)" ;  exit 1 ; }
	CHART_DIR=$(ROOT_DIR)/charts/$(PROJECT)/$(PROJECT) ; \
		[ -d "$${CHART_DIR}" ] || { echo "error, failed to find chart $${CHART_DIR}" ; exit 1 ; } ; \
		if [ "$(TRY_LOAD_LOCAL_IMAGE)" == "true" ] ; then \
			echo "try to load local image for $(PROJECT)" ; \
			IMAGE_LIST=` helm template test $${CHART_DIR}  | grep " image: " | tr -d '"'| awk '{print $$2}' ` ; \
			if [ -z "$${IMAGE_LIST}" ] ; then \
			  	echo "warning, failed to find image from chart template for $(PROJECT)" ; \
			else \
				echo "found image from $(PROJECT) chart template: $${IMAGE_LIST} " ; \
  				for IMAGE in $${IMAGE_LIST} ; do \
  				    EXIST=` docker images | awk '{printf("%s:%s\n",$$1,$$2)}' | grep "$${IMAGE}" ` ; \
  				    if [ -z "$${EXIST}" ] ; then \
  				      echo "docker pull $${IMAGE} to local" ; \
  				      docker pull $${IMAGE} ;\
  				    fi ;\
  					echo "load local image $${IMAGE} for $(PROJECT)" ; \
  					kind load docker-image $${IMAGE}  --name $(KIND_CLUSTER_NAME)  ; \
  				done ; \
            fi ; \
		fi  ;\
		chmod +x $(INSTALL_PATH) ; \
		if $(INSTALL_PATH) "$(KIND_KUBECONFIG)" "$(KIND_CLUSTER_NAME)" ; then \
			echo "succeeded to deploy $(PROJECT)" ; \
			exit 0 ; \
		else  \
			echo "error, failed to deploy $(PROJECT) "   ; \
			exit 1 ; \
		fi

.PHONY: checkBin
checkBin:
	which kind &>/dev/null || { echo "error, please install kind" ; exit 1 ; }
	which kubectl &>/dev/null || { echo "error, please install kubectl" ; exit 1 ; }
	which relok8s &>/dev/null || { make install-relok8s; }
	which charts-syncer &>/dev/null || { make install-charts-syncer; }

.PHONY: install-relok8s
install-relok8s:
	VERSION=0.5.1 ;\
	curl -OL https://github.com/vmware-tanzu/asset-relocation-tool-for-kubernetes/releases/download/v$${VERSION}/relok8s_$${VERSION}_linux_x86_64.tar.gz  ;\
	tar -zvxf relok8s_$${VERSION}_linux_x86_64.tar.gz && mv relok8s /usr/local/bin/relok8s && rm -rf README.md relok8s*.tar.gz

.PHONY: install-charts-syncer
 install-charts-syncer:
	VERSION=0.0.5 ; \
	curl -OL https://github.com/DaoCloud/charts-syncer/releases/download/v$${VERSION}/charts-syncer_$${VERSION}_linux_x86_64.tar.gz ; \
	tar -zvxf charts-syncer_$${VERSION}_linux_x86_64.tar.gz && mv charts-syncer /usr/local/bin/charts-syncer && rm -rf README.md charts-syncer*.tar.gz

.PHONY: clean
clean: checkBin
	- kind delete cluster --name  $(KIND_CLUSTER_NAME)
	- rm -f $(KIND_KUBECONFIG)
