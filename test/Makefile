include ../Makefile.defs

PROJECT ?=
KIND_CLUSTER_NAME ?= network-chart
RUN_ON_LOCAL ?= false
KIND_NODE_TAG ?= v1.25.0
KIND_KUBECONFIG := $(ROOT_DIR)/test/.config

.PHONY: all
all: e2e

.PHONY: e2e
e2e:
	#setup global kind
	make init-kind -e KIND_CONFIG_PATH=./yaml/kind.yaml || { echo "error, failed to setup kind " ; exit 1 ; }
	PROJECT_LIST="$(PROJECT)" ; [ -n "$${PROJECT_LIST}" ] || PROJECT_LIST=` ls ` ; \
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
			make deploy -e INSTALL_PATH=$${INSTALL_PATH}  -e PROJECT=$${ITEM} -e RUN_ON_LOCAL=$${RUN_ON_LOCAL} || { echo "error, failed to deploy $${ITEM}" ; exit 1 ; } ; \
	  	done ; \
	  	exit 0


.PHONY: init-kind
init-kind: KIND_CONFIG_PATH ?=
init-kind: checkBin clean
	[ -f $(KIND_CONFIG_PATH) ] || { echo "error, miss file KIND_CONFIG_PATH=$(KIND_CONFIG_PATH)" ; exit 1 ; }
	- sysctl -w net.ipv6.conf.all.disable_ipv6=0 || true
	- sysctl -w fs.inotify.max_user_watches=524288 || true
	- sysctl -w fs.inotify.max_user_instances=8192  || true
	kind create cluster --name  $(KIND_CLUSTER_NAME) --config $(KIND_CONFIG_PATH) --image=kindest/node:$(KIND_NODE_TAG) --kubeconfig $(KIND_KUBECONFIG)
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
deploy: checkBin
	@ echo "helm install for $(PROJECT) with $(INSTALL_PATH)"
	@ [ -f "$(INSTALL_PATH)" ] || { echo "error, failed to find INSTALL_PATH $(INSTALL_PATH)" ;  exit 1 ; } ; \
    export E2E_KIND_CLUSTER_NAME=${KIND_CLUSTER_NAME} ; \
    export RUN_ON_LOCAL=${RUN_ON_LOCAL} ; \
	CHART_DIR=$(ROOT_DIR)/charts/$(PROJECT)/$(PROJECT) ; \
		[ -d "$${CHART_DIR}" ] || { echo "error, failed to find chart $${CHART_DIR}" ; exit 1 ; } ; \
		chmod +x $(INSTALL_PATH) ; \
		if $(INSTALL_PATH) "$${CHART_DIR}"  "$(KIND_KUBECONFIG)" ; then \
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
