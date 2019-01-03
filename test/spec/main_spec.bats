# Copyright 2019 Google LLC
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
  METADATA_BASE="${fixtures}/main"
  source_stdlib
}

@test 'stdlib::main() is successful' {
  run stdlib::main
  assert_success
}

@test 'stdlib::main() returns 100 when startup-script-custom calls exit(100)' {
  METADATA_BASE="${fixtures}/main-negative" run stdlib::main
  assert_equal "$status" "100"
}

@test 'stdlib::main() stdlib::error works from startup-script-custom' {
  METADATA_BASE="${fixtures}/main-negative" run stdlib::main
  assert_output --regexp "Something went wrong"
}
