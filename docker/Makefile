# Make vars
MAKEARGS  = $(filter-out $@,$(MAKECMDGOALS))
MAKEFLAGS += --silent
MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MAKEFILE_DIR  := $(patsubst %/,%,$(dir $(MAKEFILE_PATH)))

# Docker context
DOCKER_DIR := $(MAKEFILE_DIR)

# Default command for 'make'
_list_commands:
	sh -c "echo 'List commands:'; $(MAKE) -p no_targets__ | awk -F':' '/^[a-zA-Z0-9][^\$$#\/\\t=]*:([^=]|$$)/ {split(\$$1,A,/ /);for(i in A)print A[i]}' | grep -v '__\$$' | grep -v 'Makefile'| sort"

# ----------------------------------------------------------------
# Check
# ----------------------------------------------------------------

_check_compose:
	if [ ! -f $(DOCKER_DIR)/docker-compose.yml ]; then ln -sr $(DOCKER_DIR)/docker-compose.host.yml $(DOCKER_DIR)/docker-compose.yml; fi
_check_secrets:
	mkdir -p $(DOCKER_DIR)/secrets
	if [ ! -f $(DOCKER_DIR)/secrets/xui_admin.pass ]; then tr -dc A-Za-z0-9 < /dev/urandom | head -c 20 > $(DOCKER_DIR)/secrets/xui_admin.pass; fi
_check_volumes:
	mkdir -p $(DOCKER_DIR)/volumes/xui_data

# ----------------------------------------------------------------
# General
# ----------------------------------------------------------------

build: _check_compose
	docker compose -f $(DOCKER_DIR)/docker-compose.yml build
build-host:
	docker compose -f $(DOCKER_DIR)/docker-compose.host.yml build

up: _check_compose
	docker compose -f $(DOCKER_DIR)/docker-compose.yml up -d
up-host:
	docker compose -f $(DOCKER_DIR)/docker-compose.host.yml up -d

down: _check_compose
	docker compose -f $(DOCKER_DIR)/docker-compose.yml down
down-host:
	docker compose -f $(DOCKER_DIR)/docker-compose.host.yml down

start: _check_compose
	docker compose -f $(DOCKER_DIR)/docker-compose.yml start
start-host:
	docker compose -f $(DOCKER_DIR)/docker-compose.host.yml start

stop: _check_compose
	docker compose -f $(DOCKER_DIR)/docker-compose.yml stop
stop-host:
	docker compose -f $(DOCKER_DIR)/docker-compose.host.yml stop

restart: _check_compose
	docker compose -f $(DOCKER_DIR)/docker-compose.yml restart
restart-host:
	docker compose -f $(DOCKER_DIR)/docker-compose.host.yml restart

ps: _check_compose
	docker compose -f $(DOCKER_DIR)/docker-compose.yml ps
ps-host:
	docker compose -f $(DOCKER_DIR)/docker-compose.host.yml ps

# ----------------------------------------------------------------
# Run
# ----------------------------------------------------------------

_before_run: \
	_check_volumes \
	_check_secrets

run: _before_run \
	up
run-host: _before_run \
	up-host

# Fix arguments
%:
	@:
