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
	kind create cluster --name  $(KIND_CLUSTER_NAME) --config $(KIND_CONFIG_PATH)  --kubeconfig $(KIND_KUBECONFIG)
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


.PHONY: deploy
deploy: INSTALL_PATH=
deploy: PROJECT=
deploy: TRY_LOAD_LOCAL_IMAGE ?= true
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
		if $(INSTALL_PATH) "$${CHART_DIR}"  "$(KIND_KUBECONFIG)" "$(KIND_CLUSTER_NAME)" ; then \
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

.PHONY: clean
clean: checkBin
	- kind delete cluster --name  $(KIND_CLUSTER_NAME)
	- rm -f $(KIND_KUBECONFIG)
