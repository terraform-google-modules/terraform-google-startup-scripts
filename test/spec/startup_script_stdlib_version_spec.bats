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

@test "STARTUP_SCRIPT_STDLIB_INITIALIZED is initialized to 0" {
  assert_equal "${STARTUP_SCRIPT_STDLIB_INITIALIZED}" "0"
}

# These error codes are expected to be part of a stable API
@test "E_RUN_OR_DIE error code is 5" {
  assert_equal "${E_RUN_OR_DIE}" "5"
}

@test "E_MISSING_MANDATORY_ARG error code is 9" {
  assert_equal "${E_MISSING_MANDATORY_ARG}" "9"
}

@test "E_UNKNOWN_ARG error code is 10" {
  assert_equal "${E_UNKNOWN_ARG}" "10"
}
