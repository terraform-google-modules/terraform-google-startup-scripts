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

load "test_helper/load"

setup() {
  # Stub out metadata_get calls with fixture data
  fixtures="file://localhost/${BATS_TEST_DIRNAME#/}/fixtures"
  METADATA_BASE="${fixtures}/load_config_values"
  source_stdlib
}

# Test helper to load config vars and return the value on STDOUT because the run
# helper executes a subshell, which discards the enviornment.
test_subject() {
  local rval
  DEBUG=1 stdlib::load_config_values
  rval=$?
  echo "${MY_CONFIG_VAR}"
  return ${rval}
}

@test 'stdlib::load_config_values() sources instance/attributes/startup-script-config' {
  run test_subject
  assert_success
  assert_equal "${lines[-1]}" "MY_VALUE"
}

# The behavior used to be that startup-scripts would print a scary error
# message, even if instance/attributes/startup-script-config exists.
# (This covers the case where metadata_get returns 0.)
@test 'load_config_values() does not print an error when instance/attributes/startup-script-config exists' {
  run stdlib::load_config_values
  assert_success
  # assert_equal is used to get nice output if there is an error line.
  assert_equal "$(grep -i error <<<"${output}")" ''
}

# The behavior used to be that startup-scripts would print a scary error
# message, even if instance/attributes/startup-script-config exists.
# (This covers the case where metadata_get returns 37)
@test 'load_config_values() with no metadata key produces no output and returns(0)' {
  METADATA_BASE="file://localhost/dev/null" run stdlib::load_config_values
  assert_success
  assert_equal "${output}" ''
}

