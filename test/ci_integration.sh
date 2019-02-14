#! /bin/bash
# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Entry point for CI Integration Tests.  This script is expected to be run
# inside the same docker image specified in the CI Pipeline definition.

# This is broken up into functions so that it may be sourced from a shell run
# via `make integration_test_shell` to initialize service account and tf input
# vars.

# Always clean up.
DELETE_AT_EXIT="$(mktemp -d)"
finish() {
  echo 'BEGIN: finish() trap handler' >&2
  bundle exec kitchen destroy
  [[ -d "${DELETE_AT_EXIT}" ]] && rm -rf "${DELETE_AT_EXIT}"
  echo 'END: finish() trap handler' >&2
}

# Map the input parameters provided by Concourse CI, or whatever mechanism is
# running the tests to Terraform input variables.  Also setup credentials for
# use with kitchen-terraform, inspec, and gcloud.
setup_environment() {
  local tmpfile
  local uuid
  tmpfile="$(mktemp)"
  echo "${SERVICE_ACCOUNT_JSON}" > "${tmpfile}"

  # Terraform and most other tools respect GOOGLE_CREDENTIALS
  export GOOGLE_CREDENTIALS="${SERVICE_ACCOUNT_JSON}"
  # gcloud variables
  export CLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE="${tmpfile}"
  export CLOUDSDK_CORE_PROJECT="${PROJECT_ID}"

  # Terraform input variables
  export TF_VAR_project_id="${PROJECT_ID}"
  export TF_VAR_region="${REGION:-us-east4}"

  # Unique ID used for resource names
  uuid="$(</proc/sys/kernel/random/uuid)"
  export UNIQUE_ID="${uuid:0:8}"
}

main() {
  set -eu
  # Setup trap handler to auto-cleanup
  export TMPDIR="${DELETE_AT_EXIT}"
  trap finish EXIT
  # Setup environment
  setup_environment
  set -x
  # Execute the test lifecycle
  bundle exec kitchen create
  bundle exec kitchen converge
  bundle exec kitchen verify
}

# if script is being executed and not sourced.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
