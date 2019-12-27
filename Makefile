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
	@grep -E '^[a-zA-Z\-\_0-9\.@]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

### ENVIRONMENT

start: _prepare_env ## Start the environment (params: VERSION)
	${SUDO} bash -c "VERSION=${VERSION} ${COMPOSE_CMD} up"

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

### CI

build_image: ## Build the image (params: VERSION, VERSION_FRONT)
	version_front=${VERSION_FRONT}; \
	version_front=$${version_front:-${VERSION}}; \
	version_front=$${version_front/-stable/}; \
	\
	set -x; ${SUDO} docker build . -f Dockerfile \
		--build-arg TAIGA_BACK_VERSION=${VERSION} \
		--build-arg TAIGA_FRONT_VERSION=$${version_front}${VERSION_FRONT_SUFFIX} \
		-t quay.io/riotkit/taiga:${VERSION}

push_image: ## Push the image to the registry (params: VERSION, GIT_TAG)
	# main tag version eg. Taiga:4.12
	${SUDO} docker push quay.io/riotkit/taiga:${VERSION}

	# We consider Taiga version + OUR BUILD VERSION, as we maintain also a project - dockerized infrastructure
	# that has it's own tags and we would like to introduce bugfixes and improvements to the existing Taiga released tags
	# eg. Taiga:4.12-b1.1
	if [[ "${GIT_TAG}" != "" ]]; then \
		${SUDO} docker tag quay.io/riotkit/taiga:${VERSION} quay.io/riotkit/taiga:${VERSION}-b${GIT_TAG}; \
		${SUDO} docker push quay.io/riotkit/taiga:${VERSION}-b${GIT_TAG}; \
	fi

ci@test:
	echo " >> Test: GIT_TAG=${GIT_TAG}, VERSION=${VERSION}, VERSION_FRONT=${VERSION_FRONT}"

### COMMON AUTOMATION

dev@generate_readme: ## Renders the README.md from README.md.j2
	RIOTKIT_PATH=./.helpers ./.helpers/docker-generate-readme

dev@before_commit: dev@generate_readme ## Git hook before commit
	git add README.md

dev@develop: ## Setup development environment, install git hooks
	echo " >> Setting up GIT hooks for development"
	mkdir -p .git/hooks
	echo "#\!/bin/bash" > .git/hooks/pre-commit
	echo "make dev@before_commit" >> .git/hooks/pre-commit
	chmod +x .git/hooks/pre-commit

ci@all: _download_tools ## Build all recent versions from github (Params: GIT_TAG)
	# Builds a few recent versions of Taiga. If docker-taiga was tagged, then force rebuilds few latest previous releases
	# without overwritting already pushed docker tags. Example: taiga:4.12 was already released, so we will push taiga:4.12-b1.1

	BUILD_PARAMS="--dont-rebuild "; \
	RELEASE_TAG_TEMPLATE="%MATCH_0%"; \
	if [[ "$$COMMIT_MESSAGE" == *"@force-rebuild"* ]] || [[ "${GIT_TAG}" != "" ]]; then \
		BUILD_PARAMS=" "; \
		if [[ "${GIT_TAG}" != "" ]]; then \
			RELEASE_TAG_TEMPLATE="%MATCH_0%-b${GIT_TAG}"; \
		fi; \
	fi; \
	set -x; \
	./.helpers/for-each-github-release --exec "make build_image push_image VERSION=%MATCH_0% VERSION_FRONT=\$$($$(pwd)/.helpers/find-closest-release taigaio/taiga-front-dist %MATCH_0%) GIT_TAG=$$GIT_TAG" --repo-name taigaio/taiga-back --dest-docker-repo quay.io/riotkit/taiga $${BUILD_PARAMS}--allowed-tags-regexp="([0-9\.]+)$$" --release-tag-template="$${RELEASE_TAG_TEMPLATE}" --max-versions=5 --verbose

_download_tools:
	curl -s -f https://raw.githubusercontent.com/riotkit-org/ci-utils/${RIOTKIT_UTILS_VER}/bin/extract-envs-from-dockerfile > .helpers/extract-envs-from-dockerfile
	curl -s -f https://raw.githubusercontent.com/riotkit-org/ci-utils/${RIOTKIT_UTILS_VER}/bin/find-closest-github-release  > .helpers/find-closest-release
	curl -s -f https://raw.githubusercontent.com/riotkit-org/ci-utils/${RIOTKIT_UTILS_VER}/bin/env-to-json                  > .helpers/env-to-json
	curl -s -f https://raw.githubusercontent.com/riotkit-org/ci-utils/${RIOTKIT_UTILS_VER}/bin/for-each-github-release      > .helpers/for-each-github-release
	curl -s -f https://raw.githubusercontent.com/riotkit-org/ci-utils/${RIOTKIT_UTILS_VER}/bin/docker-generate-readme       > .helpers/docker-generate-readme
	chmod +x .helpers/extract-envs-from-dockerfile .helpers/env-to-json .helpers/for-each-github-release .helpers/docker-generate-readme .helpers/find-closest-release
