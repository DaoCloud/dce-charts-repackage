include ../Makefile.defs

PROJECT ?=
KIND_CLUSTER_NAME ?= network-chart
KIND_KUBECONFIG := $(ROOT_DIR)/test/.config

.PHONY: all
all: e2e

.PHONY: e2e
e2e:
	PROJECT_LIST=$(PROJECT) ; [ -n "$${PROJECT_LIST}" ] || PROJECT_LIST=` ls ` ; \
		for ITEM in $$PROJECT_LIST ; do \
		    [ -d "$${ITEM}" ] || continue ; \
			CONFIG_PATH=$(ROOT_DIR)/test/$${ITEM}/kind.yaml ;\
			INSTALL_PATH=$(ROOT_DIR)/test/$${ITEM}/install.sh ;\
			if [ -n "$(PROJECT)" ]; then \
			    [ -f "$${CONFIG_PATH}" ] || { echo "error, miss $${CONFIG_PATH}" ; exit 1 ; } ; \
			    [ -f "$${INSTALL_PATH}" ] || { echo "error, miss $${INSTALL_PATH}" ; exit 1 ; } ; \
			else \
  				[ -f "$${CONFIG_PATH}" ] || { echo "warning, miss $${CONFIG_PATH}"  ; continue ; } ; \
  				[ -f "$${INSTALL_PATH}" ] || { echo "warning, miss $${INSTALL_PATH}"  ; continue ; } ; \
            fi ;\
            echo "run e2e for project $${ITEM} "  ;\
            echo "setup kind for project $${ITEM}"  ;\
			make init-kind -e KIND_CONFIG_PATH=$${CONFIG_PATH} || { echo "error, failed to setup kind for $${ITEM}" ; exit 1 ; } ;\
            echo "deploy project $${ITEM}"  ;\
			make deploy -e INSTALL_PATH=$${INSTALL_PATH}  -e PROJECT=$${ITEM} || { echo "error, failed to deploy $${ITEM}" ; exit 1 ; } ;\
	  	done


.PHONY: init-kind
init-kind: KIND_CONFIG_PATH ?=
init-kind: checkBin clean
	[ -f $(KIND_CONFIG_PATH) ] || { echo "error, miss file KIND_CONFIG_PATH=$(KIND_CONFIG_PATH)" ; exit 1 ; }
	kind create cluster --name  $(KIND_CLUSTER_NAME) --config $(KIND_CONFIG_PATH) --kubeconfig $(KIND_KUBECONFIG)
	# install servicemonitor
	kubectl apply --kubeconfig $(KIND_KUBECONFIG) -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
	# install podmonitor
	kubectl apply --kubeconfig $(KIND_KUBECONFIG) -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
	# install prometheusrules
	kubectl apply --kubeconfig $(KIND_KUBECONFIG) -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
	# install probe
	kubectl apply --kubeconfig $(KIND_KUBECONFIG) -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
	@echo "========================================================"
	@echo "   deploy kind cluster $(KIND_CLUSTER_NAME)             "
	@echo "  kubectl get node --kubeconfig $(KIND_KUBECONFIG)      "
	@echo "========================================================"


.PHONY: deploy
deploy: INSTALL_PATH?=
deploy: PROJECT?=
deploy: checkBin
	@ echo "helm install for $(PROJECT) with $(INSTALL_PATH)"
	@ [ -f "$(INSTALL_PATH)" ] || { echo "error, failed to find INSTALL_PATH $(INSTALL_PATH)" ;  exit 1 ; }
	@ CHART_DIR=$(ROOT_DIR)/charts/$(PROJECT)/$(PROJECT) ; \
		[ -d "$${CHART_DIR}" ] || { echo "error, failed to find chart $${CHART_DIR}" ; exit 1 ; } ; \
		chmod +x $(INSTALL_PATH) ; \
		$(INSTALL_PATH) "$${CHART_DIR}"  "$(KIND_KUBECONFIG)" ; \
		(($?==0)) || { echo "error, failed to deploy $(PROJECT) "  ; exit 1 ; }
	echo "succeeded to deploy $(PROJECT)"


.PHONY: checkBin
checkBin:
	which kind &>/dev/null || { echo "error, please install kind" ; exit 1 ; }
	which kubectl &>/dev/null || { echo "error, please install kubectl" ; exit 1 ; }

.PHONY: clean
clean: checkBin
	- kind delete cluster --name  $(KIND_CLUSTER_NAME)
	- rm -f $(KIND_KUBECONFIG)
