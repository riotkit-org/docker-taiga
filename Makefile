.PHONY: help
.SILENT:

SUDO=sudo
IMAGE=quay.io/riotkit/taiga
VERSION_FRONT_SUFFIX=-stable
ENV_NAME=taiga
COMPOSE_CMD=docker-compose -p ${ENV_NAME}
SHELL=/bin/bash
RIOTKIT_UTILS_VER=v1.2.3

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

ci@build: ## Build the image (params: VERSION, VERSION_FRONT)
	${SUDO} docker build . -f Dockerfile \
		--build-arg TAIGA_BACK_VERSION=${VERSION} \
		--build-arg TAIGA_FRONT_VERSION=${VERSION_FRONT}${VERSION_FRONT_SUFFIX} \
		-t quay.io/riotkit/taiga:${VERSION}

ci@push: ## Push the image to the registry (params: VERSION)
	${SUDO} docker tag quay.io/riotkit/taiga:${VERSION} quay.io/riotkit/taiga:${VERSION}-$$(date '+%Y-%m-%d')
	${SUDO} docker push quay.io/riotkit/taiga:${VERSION}-$$(date '+%Y-%m-%d')
	${SUDO} docker push quay.io/riotkit/taiga:${VERSION}

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

ci@all: _download_tools ## Build all recent versions from github
	BUILD_PARAMS="--dont-rebuild "; \
	if [[ "$$TRAVIS_COMMIT_MESSAGE" == *"@force-rebuild"* ]]; then \
		BUILD_PARAMS=" "; \
	fi; \
	./.helpers/for-each-github-release --exec "make ci@build ci@push VERSION=%RELEASE_TAG% VERSION_FROMT=%RELEASE_TAG%-stable" --repo-name taigaio/taiga-back --dest-docker-repo quay.io/riotkit/taiga $${BUILD_PARAMS}--allowed-tags-regexp="([0-9\.]+)$$" --release-tag-template="%MATCH_0%" --max-versions=5 --verbose

_download_tools:
	curl -s https://raw.githubusercontent.com/riotkit-org/ci-utils/${RIOTKIT_UTILS_VER}/bin/extract-envs-from-dockerfile > .helpers/extract-envs-from-dockerfile
	curl -s https://raw.githubusercontent.com/riotkit-org/ci-utils/${RIOTKIT_UTILS_VER}/bin/env-to-json                  > .helpers/env-to-json
	curl -s https://raw.githubusercontent.com/riotkit-org/ci-utils/${RIOTKIT_UTILS_VER}/bin/for-each-github-release      > .helpers/for-each-github-release
	curl -s https://raw.githubusercontent.com/riotkit-org/ci-utils/${RIOTKIT_UTILS_VER}/bin/docker-generate-readme       > .helpers/docker-generate-readme
	chmod +x .helpers/extract-envs-from-dockerfile .helpers/env-to-json .helpers/for-each-github-release .helpers/docker-generate-readme
