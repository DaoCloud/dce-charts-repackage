#!/usr/bin/make -f

# Copyright 2022 Authors of spidernet-io
# SPDX-License-Identifier: Apache-2.0

include Makefile.defs

.PHONY: all
all: build_chart

PROJECT ?=

.PHONY: e2e
e2e:
	make -C test e2e -e PROJECT="$(PROJECT)"

.PHONY: build_chart
build_chart:
	@ project=$(PROJECT) ; [ -z "$(PROJECT)" ] && project=`ls ./charts` ; \
		echo "build chart for $${project}" ; \
		for ITEM in $${project} ; do\
			echo "===================== build $${ITEM} ====================" ; \
			./scripts/generateChart.sh $${ITEM} ; \
		done

.PHONY: help
help:
	@echo "make         					 build all chart under /charts"
	@echo "make -e PROJECT=spiderpool        just build spiderpool chart"

