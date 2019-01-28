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

load "${BATS_PREFIX}/../bats-support/load.bash"
load "${BATS_PREFIX}/../bats-assert/load.bash"
load "${BATS_PREFIX}/../bats-mock/stub.bash"

bats_delete_at_exit="$(mktemp -d)"
bats_finish() {
  [[ -d "$bats_delete_at_exit" ]] && rm -rf "$bats_delete_at_exit"
}
trap bats_finish EXIT

# Automatically cleaned up temp files.
bats_mktemp() {
  TMPDIR="${bats_delete_at_exit}" mktemp "$@"
}

# Assert against this file to validate syslog commands.
LOGGER_COMMAND_LIST="$(bats_mktemp)"
# Stub out the logger command and store invocations for later assertions.
logger() {
  echo "logger $*" >> "$LOGGER_COMMAND_LIST"
}

# Assert a specific syslog command has been run
assert_syslog() {
  local expected="$*"
  local output="$(cat "$LOGGER_COMMAND_LIST")"
  if ! grep -q "$expected" "$LOGGER_COMMAND_LIST"; then
    batslib_print_kv_single_or_multi 6 \
      'regexp' "$expected" \
      'output' "$output" \
      | batslib_decorate 'expected logger command was not run' \
      | fail
  fi
}

# Assert no log commands have run.
assert_no_logger() {
  if [[ -s "$LOGGER_COMMAND_LIST" ]]; then
    batslib_print_kv_single_or_multi 6 \
      'output' "$(cat "$LOGGER_COMMAND_LIST")" \
      | batslib_decorate 'expected no logger commands, but logger was executed' \
      | fail
  fi
}

# Assert against this file to validate install commands.
INSTALL_COMMAND_LIST="$(bats_mktemp)"
# Stub out the logger command for use with assert_install and assert_no_install
install() {
  echo "install $*" >> "$INSTALL_COMMAND_LIST"
}

# Assert a specific install command has been run
assert_install() {
  local expected="$*"
  if ! grep -q "$expected" "$INSTALL_COMMAND_LIST"; then
    batslib_print_kv_single_or_multi 6 \
      'regexp' "$expected" \
      'output' "$(cat "$INSTALL_COMMAND_LIST")" \
      | batslib_decorate 'expected install command was not run' \
      | fail
  fi
}

assert_no_install() {
  if [[ -s "$INSTALL_COMMAND_LIST" ]]; then
    batslib_print_kv_single_or_multi 6 \
      'output' "$(cat "$INSTALL_COMMAND_LIST")" \
      | batslib_decorate 'expected no install commands, but install was executed' \
      | fail
  fi
}

GSUTIL_COMMAND_LIST="$(bats_mktemp)"
# Stub out the gsutil command storing complete argument vectors for laterk
# assertions.
gsutil() {
  echo "gsutil $*" >> "$GSUTIL_COMMAND_LIST"
}

# Assert an expected gsutil command has been run
assert_gsutil() {
  local expected="$*"
  if ! grep -q "$expected" "$GSUTIL_COMMAND_LIST"; then
    batslib_print_kv_single_or_multi 6 \
      'regexp' "$expected" \
      'output' "$(cat "$GSUTIL_COMMAND_LIST")" \
      | batslib_decorate 'expected gsutil command was not run' \
      | fail
  fi
}

# When running on a non-linux machine, override default values.  These values
# are intended to get the test suite running on a Mac OS X system.  Change
# appropriately depending on the context (e.g. in CI/CD)
if ! [[ -e /proc ]]; then
  export SYSLOG_DEBUG_PRIORITY="user.debug"
  export SYSLOG_INFO_PRIORITY="user.info"
  export SYSLOG_ERROR_PRIORITY="user.error"
  VARDIR="$(bats_mktemp -d)"
  export VARDIR
fi

# Use in setup(), separated out so setup() may be overridden.
source_stdlib() {
  local statefile
  statefile="$(bats_mktemp)"
  stdlib="$(bats_mktemp)"

  ( cd "${BATS_TEST_DIRNAME%/}/../../" || return 1;
    terraform init -input=false;
    terraform apply -input=false -state-out="${statefile}";
    terraform output -state="${statefile}" content > "${stdlib}")
  # shellcheck source=/dev/null
  source "${stdlib}"
  rm -f "${stdlib}" "${statefile}"
}

# Load and initialize the function library before each test.
setup() {
  source_stdlib
}

# Clear out the logging command list after every test.
teardown() {
  local fp
  for fp in "$LOGGER_COMMAND_LIST" "$INSTALL_COMMAND_LIST"; do
    if [[ -e "$fp" ]]; then
      echo -n '' > "$fp"
    fi
  done
}
