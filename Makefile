SUDO=sudo
IMAGE=quay.io/riotkit/taiga
VERSION=4.2.5
VERSION_FRONT=${VERSION}-stable
ENV_NAME=taiga
COMPOSE_CMD=docker-compose -p ${ENV_NAME}

all: build push

## Build the image
build:
	${SUDO} docker build . -f Dockerfile \
		--build-arg TAIGA_BACK_VERSION=${VERSION} \
		--build-arg TAIGA_FRONT_VERSION=${VERSION_FRONT} \
		-t quay.io/riotkit/taiga:${VERSION}

## Push the image to the registry
push:
	${SUDO} docker push quay.io/riotkit/taiga:${VERSION}

## Start the environment
start: _prepare_env
	${SUDO} bash -c "VERSION=${VERSION} ${COMPOSE_CMD} up"

## Start the environment in the background
start_detached: _prepare_env
	${SUDO} bash -c "VERSION=${VERSION} ${COMPOSE_CMD} up -d"

## Get a shell inside of the container
shell: _prepare_env
	${SUDO} ${COMPOSE_CMD} exec taiga bash

## Delete all data, including postgres data and uploads
delete_environment: _prepare_env
	${SUDO} docker volume rm ${ENV_NAME}_postgres || true
	${SUDO} docker volume rm ${ENV_NAME}_media || true
	${SUDO} ${COMPOSE_CMD} rm -f

_prepare_env:
	test -f .env || cp .env.dist .env
