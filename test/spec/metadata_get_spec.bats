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
  export METADATA_BASE="file://localhost/${BATS_TEST_DIRNAME#/}/fixtures/metadata_get"
  source_stdlib
}

@test 'stdlib::metadata_get -k instance/attributes/some-key writes some-value to STDOUT' {
  run stdlib::metadata_get -k 'instance/attributes/some-key'
  assert_success
  assert_output 'some-value'
}

@test 'stdlib::metadata_get -k instance/attributes/some-key -o <file> writes some-value to <file>' {
  local output_file="$(bats_mktemp)"
  run stdlib::metadata_get -k 'instance/attributes/some-key' -o "$output_file"
  assert_success
  assert_output ''
  assert_equal "$(cat "${output_file}")" 'some-value'
}

@test 'stdlib::metadata_get -k with missing argument prints Error, Usage and returns E_MISSING_MANDATORY_ARG' {
  run stdlib::metadata_get -k
  assert_equal "$status" "$E_MISSING_MANDATORY_ARG"
  assert_output --regexp 'Error .* Invalid option: -k requires an argument'
  assert_output --regexp 'Info .* Usage: stdlib::metadata_get'
}

@test 'stdlib::metadata_get with invalid arguments prints Error, Usage and returns(E_UNKNOWN_ARG)' {
  run stdlib::metadata_get -x -z -v
  assert_equal "$status" "$E_UNKNOWN_ARG"
  assert_output --regexp 'Error .* Usage: stdlib::metadata_get'
  assert_output --regexp 'For example:'
}
