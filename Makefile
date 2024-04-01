# Makefile

EDGELAKE_TYPE := generic
ifneq ($(filter-out $@,$(MAKECMDGOALS)), )
	EDGELAKE_TYPE = $(filter-out $@,$(MAKECMDGOALS))
endif
include docker_makefile/edgelake_$(EDGELAKE_TYPE).env

export EXTRACT_NODE_NAME := $(shell cat docker_makefile/edgelake_master.env | grep NODE_NAME | awk -F "=" '{print $$2}')
export DOCKER_IMAGE_BASE ?= anylogco/edgelake
export DOCKER_IMAGE_NAME ?= edgelake
export DOCKER_IMAGE_VERSION ?= 1.0.0

# DockerHub ID of the third party providing the image (usually yours if building and pushing)
export DOCKER_HUB_ID ?= anylogco
# The Open Horizon organization ID namespace where you will be publishing the service definition file
export HZN_ORG_ID ?= examples

# Open Horizon settings for publishing metadata about the service
export DEPLOYMENT_POLICY_NAME ?= deployment-policy-edgelake-$(EDGELAKE_TYPE)
export NODE_POLICY_NAME ?= node-policy-edgelake-$(EDGELAKE_TYPE)
export SERVICE_NAME ?= service-edgelake
export SERVICE_VERSION := $(shell curl -s https://raw.githubusercontent.com/EdgeLake/EdgeLake/main/setup.cfg | grep "version = " | awk -F " = " '{print $$2}')

export ARCH := $(shell uname -m)
OS := $(shell uname -s)
ifeq ($(ARCH), arm64)
	export DOCKER_IMAGE_VERSION := latest-arm64
endif

export EDGELAKE_VOLUME := edgelake-$(EDGELAKE_TYPE)-anylog
export BLOCKCHAIN_VOLUME := edgelake-$(EDGELAKE_TYPE)-blockchain
export DATA_VOLUME := edgelake-$(EDGELAKE_TYPE)-data
export LOCAL_SCRIPTS_VOLUME := edgelake-$(EDGELAKE_TYPE)-local-scripts

all: help-docker help-open-horizon
build:
	docker pull anylogco/edgelake:latest
up:
	@echo "Deploy AnyLog with config file: anylog_$(EDGELAKE_TYPE).env"
	EDGELAKE_TYPE=$(EDGELAKE_TYPE) envsubst < docker_makefile/docker-compose-template.yaml > docker_makefile/docker-compose.yaml
	@docker-compose -f docker_makefile/docker-compose.yaml up -d
	@rm -rf docker_makefile/docker-compose.yaml
down:
	EDGELAKE_TYPE=$(EDGELAKE_TYPE) envsubst < docker_makefile/docker-compose-template.yaml > docker_makefile/docker-compose.yaml
	@docker-compose -f docker_makefile/docker-compose.yaml down
	@rm -rf docker_makefile/docker-compose.yaml
clean:
	EDGELAKE_TYPE=$(EDGELAKE_TYPE) envsubst < docker_makefile/docker-compose-template.yaml > docker_makefile/docker-compose.yaml
	@docker-compose -f docker_makefile/docker-compose.yaml down -v --remove-orphans --rmi all
	@rm -rf docker_makefile/docker-compose.yaml
attach:
	docker attach --detach-keys=ctrl-d edgelake-$(EDGELAKE_TYPE)
node-status:
	@if [ "$(EDGELAKE_TYPE)" = "master" ]; then \
		curl -X GET 127.0.0.1:32049 -H "command: get status" -H "User-Agent: AnyLog/1.23" -w "\n"; \
	elif [ "$(EDGELAKE_TYPE)" = "operator" ]; then \
		curl -X GET 127.0.0.1:32149 -H "command: get status" -H "User-Agent: AnyLog/1.23" -w "\n"; \
	elif [ "$(EDGELAKE_TYPE)" = "query" ]; then \
		curl -X GET 127.0.0.1:32349 -H "command: get status" -H "User-Agent: AnyLog/1.23" -w "\n"; \
	elif [ "$(NODE_TYPE)" == "generic" ]; then \
		curl -X GET 127.0.0.1:32549 -H "command: get status" -H "User-Agent: AnyLog/1.23" -w "\n"; \
	fi
test-node:
	@if [ "$(EDGELAKE_TYPE)" = "master" ]; then \
		curl -X GET 127.0.0.1:32049 -H "command: test node" -H "User-Agent: AnyLog/1.23" -w "\n"; \
	elif [ "$(EDGELAKE_TYPE)" = "operator" ]; then \
		curl -X GET 127.0.0.1:32149 -H "command: test node" -H "User-Agent: AnyLog/1.23" -w "\n"; \
	elif [ "$(EDGELAKE_TYPE)" = "query" ]; then \
		curl -X GET 127.0.0.1:32349 -H "command: test node" -H "User-Agent: AnyLog/1.23" -w "\n"; \
	elif [ "$(NODE_TYPE)" == "generic" ]; then \
		curl -X GET 127.0.0.1:32549 -H "command: test node" -H "User-Agent: AnyLog/1.23" -w "\n"; \
	fi
test-network:
	@if [ "$(EDGELAKE_TYPE)" = "master" ]; then \
		curl -X GET 127.0.0.1:32049 -H "command: test network" -H "User-Agent: AnyLog/1.23" -w "\n"; \
	elif [ "$(EDGELAKE_TYPE)" = "operator" ]; then \
		curl -X GET 127.0.0.1:32149 -H "command: test network" -H "User-Agent: AnyLog/1.23" -w "\n"; \
	elif [ "$(EDGELAKE_TYPE)" = "query" ]; then \
		curl -X GET 127.0.0.1:32349 -H "command: test network" -H "User-Agent: AnyLog/1.23" -w "\n"; \
	elif [ "$(NODE_TYPE)" == "generic" ]; then \
		curl -X GET 127.0.0.1:32549 -H "command: test network" -H "User-Agent: AnyLog/1.23" -w "\n"; \
	fi
exec:
	docker exec -it edgelake-$(EDGELAKE_TYPE) bash
logs:
	docker logs edgelake-$(EDGELAKE_TYPE)
# Makefile for policy
publish-service:
	@echo "=================="
	@echo "PUBLISHING SERVICE"
	@echo "=================="
	@hzn exchange service publish -O -P --json-file=hzn/service.definition.json
	@echo ""
remove-service:
	@echo "=================="
	@echo "REMOVING SERVICE"
	@echo "=================="
	@hzn exchange service remove -f $(HZN_ORG_ID)/$(SERVICE_NAME)_$(SERVICE_VERSION)_$(ARCH)
	@echo ""

publish-service-policy:
	@echo "========================="
	@echo "PUBLISHING SERVICE POLICY"
	@echo "========================="
	@hzn exchange service addpolicy -f hzn/service.policy.json $(HZN_ORG_ID)/$(SERVICE_NAME)_$(SERVICE_VERSION)_$(ARCH)
	@echo ""

remove-service-policy:
	@echo "======================="
	@echo "REMOVING SERVICE POLICY"
	@echo "======================="
	@hzn exchange service removepolicy -f $(HZN_ORG_ID)/$(SERVICE_NAME)_$(SERVICE_VERSION)_$(ARCH)
	@echo ""

publish-deployment-policy:
	@echo "============================"
	@echo "PUBLISHING DEPLOYMENT POLICY"
	@echo "============================"
	@hzn exchange deployment addpolicy -f hzn/deployment.policy.$(EDGELAKE_TYPE).json $(HZN_ORG_ID)/policy-$(SERVICE_NAME)-$(EDGELAKE_TYPE)_$(SERVICE_VERSION)_$(EXTRACT_NODE_NAME).json
	@echo ""

remove-deployment-policy:
	@echo "=========================="
	@echo "REMOVING DEPLOYMENT POLICY"
	@echo "=========================="
	@hzn exchange deployment removepolicy -f hzn/deployment.policy.$(EDGELAKE_TYPE).json $(HZN_ORG_ID)/policy-$(SERVICE_NAME)-$(EDGELAKE_TYPE)_$(SERVICE_VERSION)_$(EXTRACT_NODE_NAME).json
	@echo ""

agent-run:
	@echo "================"
	@echo "REGISTERING NODE"
	@echo "================"
	@hzn register --policy=hzn/node.policy.$(EDGELAKE_TYPE).json
	@watch hzn agreement list

agent-stop:
	@echo "==================="
	@echo "UN-REGISTERING NODE"
	@echo "==================="
	@hzn unregister -f
	@echo ""

deploy-check:
	@hzn deploycheck all -t device -B hzn/deployment.policy.$(EDGELAKE_TYPE).json --service=hzn/service.definition.json --service-pol=hzn/service.policy.json --node-pol=hzn/node.policy.json
help-docker:
	@echo "Usage: make [target] EDGELAKE_TYPE=[edgelake-type]"
	@echo "Targets:"
	@echo "  all           Get help for both docker and OpenHorizon deployments"
	@echo "  build         Pull the docker image"
	@echo "  up            Start the containers"
	@echo "  attach        Attach to EdgeLake instance"
	@echo "  test          Using cURL validate node is running"
	@echo "  exec          Attach to shell interface for container"
	@echo "  down          Stop and remove the containers"
	@echo "  logs          View logs of the containers"
	@echo "  node-status   validate node is accessible via REST"
	@echo "  test-node     validate node is able to communicate and has a valid blockchain file"
	@echo "  test-network  validate node is able to communicate with other nodes witin its network"
	@echo "  clean         Clean up volumes and network"
	@echo "  help-docker   Show this help message"
	@echo "  supported EdgeLake types: generic, master, operator, and query"
	@echo "Sample calls: make up master | make attach master | make clean master"
help-open-horizon:
	@echo "Usage: make [target] EDGELAKE_TYPE=[edgelake-type]"
	@echo "Targets:"
	@echo "  all                                 Get help for both OpenHorizon and docker deployments"
	@echo "  build                               Pull the docker image"
	@echo "  publish-service                     Publish service to OpenHorizon"
	@echo "  remove-service                      Remove service from OpenHorizon"
	@echo "  publish-service-policy              Publish service policy to OpenHorizon"
	@echo "  remove-service-policy               Remove service policy from OpenHorizon"
	@echo "  publish-deployment-policy           Publish deployment policy to OpenHorizon"
	@echo "  remove-deployment-policy            Remove deployment policy from OpenHorizon"
	@echo "  agent-run                           Start service via OpenHorizon"
	@echo "  agent-stop                          Stop service via OpenHorizon"
	@echo "  deploy-check                        Check status of machine against OpenHorizon"
	@echo "  help-open-horizon                   Show this help message"
	@echo "  supported EdgeLake types: generic, master, operator, and query"

