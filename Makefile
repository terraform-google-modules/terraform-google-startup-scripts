# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Make will use bash instead of sh
SHELL := /usr/bin/env bash

# Docker build config variables
# Use commit ID's because BATS upstream does not tag releases correctly.
BUILD_BATS_VERSION ?= 03608115df2071fff4eaaff1605768c275e5f81f
BUILD_BATS_ASSERT_VERSION ?= 8200039faf9790c05d9865490c97a0e101b9c80f
BUILD_BATS_ASSERT_URI ?= https://github.com/jasonkarns/bats-assert-1.git
BUILD_BATS_MOCK_VERSION ?= 2f9811faf43593ad7b59a0f245d8807b776e5072
BUILD_BATS_SUPPORT_VERSION ?= 004e707638eedd62e0481e8cdc9223ad471f12ee
DOCKER_IMAGE_BATS := cftk/bats
# DOCKER_TAG_BATS is the image semver and has no correlation to bats versions
DOCKER_TAG_BATS ?= 0.6.0

# All is the first target in the file so it will get picked up when you just run 'make' on its own
all: check_shell check_python check_golang check_terraform check_docker check_base_files test_check_headers check_headers check_trailing_whitespace generate_docs

# The .PHONY directive tells make that this isn't a real target and so
# the presence of a file named 'check_shell' won't cause this target to stop
# working
.PHONY: check_shell
check_shell:
	@source test/make.sh && check_shell

.PHONY: check_python
check_python:
	@source test/make.sh && check_python

.PHONY: check_golang
check_golang:
	@source test/make.sh && golang

.PHONY: check_terraform
check_terraform:
	@source test/make.sh && check_terraform

.PHONY: check_docker
check_docker:
	@source test/make.sh && docker

.PHONY: check_base_files
check_base_files:
	@source test/make.sh && basefiles

.PHONY: check_trailing_whitespace
check_trailing_whitespace:
	@source test/make.sh && check_trailing_whitespace

.PHONY: test_check_headers
test_check_headers:
	@echo "Testing the validity of the header check"
	@python test/test_verify_boilerplate.py

.PHONY: check_headers
check_headers:
	@source test/make.sh && check_headers

.PHONY: generate_docs
generate_docs:
	@source test/make.sh && generate_docs

# Versioning
.PHONY: version
version:
	@source helpers/version-repo.sh

# Build Docker
.PHONY: docker_build_bats
docker_build_bats:
	docker build -f build/docker/bats/Dockerfile \
		--build-arg BUILD_BATS_VERSION=${BUILD_BATS_VERSION} \
		--build-arg BUILD_BATS_ASSERT_VERSION=${BUILD_BATS_ASSERT_VERSION} \
		--build-arg BUILD_BATS_ASSERT_URI=${BUILD_BATS_ASSERT_URI} \
		--build-arg BUILD_BATS_MOCK_VERSION=${BUILD_BATS_MOCK_VERSION} \
		--build-arg BUILD_BATS_SUPPORT_VERSION=${BUILD_BATS_SUPPORT_VERSION} \
		-t ${DOCKER_IMAGE_BATS}:${DOCKER_TAG_BATS} .

# Run docker bats spec tests
.PHONY: docker_bats
docker_bats:
	docker run --rm -it \
		-v $(CURDIR):/cftk/workdir \
		${DOCKER_IMAGE_BATS}:${DOCKER_TAG_BATS} \
		/bin/bash -c "bats test/spec/*.bats"

# Run docker bats spec tests in parallel (~30% faster)
.PHONY: docker_bats_parallel
docker_bats_parallel:
	docker run --rm -it \
		-v $(CURDIR):/cftk/workdir \
		${DOCKER_IMAGE_BATS}:${DOCKER_TAG_BATS} \
		/bin/bash -c "terraform init && time find test/spec/ -name '*.bats' -print0 | xargs -0 -P4 --no-run-if-empty -n1 bats"

# Run docker bats shell
.PHONY: docker_bats_shell
docker_bats_shell:
	docker run --rm -it \
		-v $(CURDIR):/cftk/workdir \
		${DOCKER_IMAGE_BATS}:${DOCKER_TAG_BATS} \
		/bin/bash
