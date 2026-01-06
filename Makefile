MAKEARGS = $(filter-out $@,$(MAKECMDGOALS))
MAKEDIR := ${CURDIR}
MAKEFLAGS += --silent
MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MAKEFILE_DIR := $(patsubst %/,%,$(dir $(MAKEFILE_PATH)))

# Load environments
ifneq ("$(wildcard .env)","")
	include .env
	export $(shell sed 's/=.*//' .env)
endif

# Default command for 'make'
_list_commands:
	sh -c "echo 'List commands:'; $(MAKE) -p no_targets__ | awk -F':' '/^[a-zA-Z0-9][^\$$#\/\\t=]*:([^=]|$$)/ {split(\$$1,A,/ /);for(i in A)print A[i]}' | grep -v '__\$$' | grep -v 'Makefile'| sort"

# ----------------------------------------------------------------
# Docker: General
# ----------------------------------------------------------------

_docker_check_secrets:
	mkdir -p $(MAKEFILE_DIR)/docker/secrets
	tr -dc A-Za-z0-9 < /dev/urandom | head -c 13 > $(MAKEFILE_DIR)/docker/secrets/xui_admin.pass
_docker_check_volumes:
	mkdir -p $(MAKEFILE_DIR)/docker/volumes/xui_db $(MAKEFILE_DIR)/docker/volumes/xui_logs
_docker_check_yaml:
	if [ ! -f $(MAKEFILE_DIR)/docker/docker-compose.yml ]; then cp $(MAKEFILE_DIR)/docker/docker-compose.host.yml $$(MAKEFILE_DIR)/docker/docker-compose.yml; fi
_docker_check: \
	_docker_check_secrets \
	_docker_check_volumes \
	_docker_check_yaml

docker-up: _docker_check
	docker compose -f $(MAKEFILE_DIR)/docker/docker-compose.yml up -d
docker-down: _docker_check_yaml
	docker compose -f $(MAKEFILE_DIR)/docker/docker-compose.yml down
docker-start: _docker_check
	docker compose -f $(MAKEFILE_DIR)/docker/docker-compose.yml start
docker-stop: _docker_check_yaml
	docker compose -f $(MAKEFILE_DIR)/docker/docker-compose.yml stop
docker-restart: _docker_check
	docker compose -f $(MAKEFILE_DIR)/docker/docker-compose.yml restart
docker-ps: _docker_check_yaml
	docker compose -f $(MAKEFILE_DIR)/docker/docker-compose.yml ps

# ----------------------------------------------------------------
# Docker: Build
# ----------------------------------------------------------------

docker-build:
	bash $(MAKEFILE_DIR)/bin/docker-build.sh latest
docker-build-push:
	bash $(MAKEFILE_DIR)/bin/docker-build.sh latest --push
docker-buildx:
	bash $(MAKEFILE_DIR)/bin/docker-buildx.sh latest
docker-buildx-push:
	bash $(MAKEFILE_DIR)/bin/docker-buildx.sh latest --push

# Fix arguments
%:
	@:
