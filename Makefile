.PHONY: help
.SILENT:

PREPARE := $(shell test -e .env || cp .env.dist .env)
IS_ENV_PRESENT := $(shell test -e .env && echo -n yes)

ifeq ($(IS_ENV_PRESENT), yes)
	include .env
	export $(shell sed 's/=.*//' .env)
endif

SUDO=sudo
IMAGE=quay.io/riotkit/taiga
VERSION_FRONT_SUFFIX=-stable
ENV_NAME=taiga
COMPOSE_CMD=docker-compose -p ${ENV_NAME}
SHELL=/bin/bash
RIOTKIT_UTILS_VER=v2.1.0

help:
	@grep -E '^[a-zA-Z\-\_0-9\.@]+:.*?## .*$$' Makefile | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

### ENVIRONMENT

start: _prepare_env ## Start the environment (params: VERSION)
	${SUDO} bash -c "VERSION=${VERSION} ${COMPOSE_CMD} up"

clear: ## Remove all volumes and containers
	${SUDO} bash -c "VERSION=${VERSION} ${COMPOSE_CMD} down -v"
	${SUDO} bash -c "VERSION=${VERSION} ${COMPOSE_CMD} rm -s -f -v"

start_detached: _prepare_env ## Start the environment in the background (params: VERSION)
	${SUDO} bash -c "VERSION=${VERSION} ${COMPOSE_CMD} up -d"

shell: _prepare_env ## Get a shell inside of the container
	${SUDO} ${COMPOSE_CMD} exec taiga bash

delete_environment: _prepare_env ## Delete all data, including postgres data and uploads
	${SUDO} docker volume rm ${ENV_NAME}_postgres || true
	${SUDO} docker volume rm ${ENV_NAME}_media || true
	${SUDO} ${COMPOSE_CMD} rm -f

_prepare_env:
	test -f .env || cp .env.dist .env

