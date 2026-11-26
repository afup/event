-include .env

CURRENT_UID ?= $(shell id -u)
DOCKER_UP_OPTIONS ?=

.PHONY: install docker-up docker-stop docker-downvendors

install: vendors

docker-up: .docker-build data docker-compose.override.yml
	CURRENT_UID=$(CURRENT_UID) docker-compose up $(DOCKER_UP_OPTIONS)

docker-stop:
	CURRENT_UID=$(CURRENT_UID) docker-compose stop

docker-down:
	CURRENT_UID=$(CURRENT_UID) docker-compose down

.docker-build: docker-compose.yml docker-compose.override.yml $(shell find docker -type f)
	CURRENT_UID=$(CURRENT_UID) ENABLE_XDEBUG=$(ENABLE_XDEBUG) docker-compose build
	touch .docker-build

docker-compose.override.yml:
	cp docker-compose.override.yml-dist docker-compose.override.yml

vendors:
	CURRENT_UID=$(CURRENT_UID) ENABLE_XDEBUG=$(ENABLE_XDEBUG) docker-compose run event make vendor

shell:
	CURRENT_UID=$(CURRENT_UID) ENABLE_XDEBUG=$(ENABLE_XDEBUG) docker-compose run event /bin/bash

data:
	mkdir data
	mkdir data/composer

composer.phar:
	$(eval EXPECTED_SIGNATURE = "$(shell wget -q -O - https://composer.github.io/installer.sig)")
	$(eval ACTUAL_SIGNATURE = "$(shell php -r "copy('https://getcomposer.org/installer', 'composer-setup.php'); echo hash_file('SHA384', 'composer-setup.php');")")
	@if [ "$(EXPECTED_SIGNATURE)" != "$(ACTUAL_SIGNATURE)" ]; then echo "Invalid signature"; exit 1; fi
	php composer-setup.php
	rm composer-setup.php

vendor: composer.phar composer.lock
	php composer.phar install

