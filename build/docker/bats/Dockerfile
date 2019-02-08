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

FROM alpine:3.8

# Avoid "world" build errors when pinning versions, these versions should be
# stable enough in alpine 3.8 to avoid version related failures.
# hadolint ignore=DL3018
RUN apk add --no-cache \
  bash \
  unzip \
  curl \
  git

ENV APP_BASE_DIR="/cftk"
# Directory structure used for tools and workspace.
RUN mkdir -p "${APP_BASE_DIR}/home" \
  "${APP_BASE_DIR}/bin" \
  "${APP_BASE_DIR}/workdir"

# Terraform
WORKDIR ${APP_BASE_DIR}
RUN curl -o terraform.zip https://releases.hashicorp.com/terraform/0.11.11/terraform_0.11.11_linux_amd64.zip
RUN unzip terraform.zip -d "${APP_BASE_DIR}/bin"

# bats
WORKDIR ${APP_BASE_DIR}
ARG BUILD_BATS_VERSION
ENV BATS_VERSION="${BUILD_BATS_VERSION}"
RUN git clone "https://github.com/sstephenson/bats.git"
WORKDIR ${APP_BASE_DIR}/bats
RUN git checkout ${BATS_VERSION} -b v${BATS_VERSION}

# bats-support
WORKDIR ${APP_BASE_DIR}
ARG BUILD_BATS_SUPPORT_VERSION
ENV BATS_SUPPORT_VERSION="${BUILD_BATS_SUPPORT_VERSION}"
RUN git clone "https://github.com/ztombol/bats-support.git"
WORKDIR ${APP_BASE_DIR}/bats-support
RUN git checkout ${BATS_SUPPORT_VERSION} -b v${BATS_SUPPORT_VERSION}

# bats-assert
WORKDIR ${APP_BASE_DIR}
ARG BUILD_BATS_ASSERT_URI
ENV BATS_ASSERT_URI="${BUILD_BATS_ASSERT_URI}"
ARG BUILD_BATS_ASSERT_VERSION
ENV BATS_ASSERT_VERSION="${BUILD_BATS_ASSERT_VERSION}"
RUN git clone "${BATS_ASSERT_URI}" bats-assert
WORKDIR ${APP_BASE_DIR}/bats-assert
RUN git checkout ${BATS_ASSERT_VERSION} -b v${BATS_ASSERT_VERSION}

# bats-mock
WORKDIR ${APP_BASE_DIR}
ARG BUILD_BATS_MOCK_VERSION
ENV BATS_MOCK_VERSION="${BUILD_BATS_MOCK_VERSION}"
RUN git clone "https://github.com/jasonkarns/bats-mock.git"
WORKDIR ${APP_BASE_DIR}/bats-mock
RUN git checkout ${BATS_MOCK_VERSION} -b v${BATS_MOCK_VERSION}

ENV HOME="${APP_BASE_DIR}/home"
ENV PATH ${APP_BASE_DIR}/bats/bin:${APP_BASE_DIR}/bin:$PATH

WORKDIR ${APP_BASE_DIR}/workdir
