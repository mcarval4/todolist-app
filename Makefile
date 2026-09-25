SHELL := /bin/sh

CLUSTER_NAME ?= todolist-demo
TF_CLUSTER := infra/cluster
TF_PLATFORM := infra/platform

.PHONY: preflight bootstrap destroy fmt validate test-ha evidence

preflight:

	./scripts/preflight.sh

bootstrap: preflight

	terraform -chdir=$(TF_CLUSTER) init
	terraform -chdir=$(TF_CLUSTER) apply -auto-approve
	kind export kubeconfig --name $(CLUSTER_NAME)
	helm repo update
	terraform -chdir=$(TF_PLATFORM) init
	terraform -chdir=$(TF_PLATFORM) apply -auto-approve

destroy:

	terraform -chdir=$(TF_PLATFORM) destroy -auto-approve
	terraform -chdir=$(TF_CLUSTER) destroy -auto-approve

fmt:

	terraform -chdir=$(TF_CLUSTER) fmt -recursive
	terraform -chdir=$(TF_PLATFORM) fmt -recursive

validate:

	terraform -chdir=$(TF_CLUSTER) init -backend=false
	terraform -chdir=$(TF_CLUSTER) validate
	terraform -chdir=$(TF_PLATFORM) init -backend=false
	terraform -chdir=$(TF_PLATFORM) validate

test-ha:

	./tests/ha/run.sh

evidence:

	./scripts/collect-evidence.sh
