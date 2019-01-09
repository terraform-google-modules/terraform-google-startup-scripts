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

@test 'STARTUP_SCRIPT_STDLIB_INITIALIZED is 0 when stdlib is sourced' {
  assert_equal "$STARTUP_SCRIPT_STDLIB_INITIALIZED" '0'
}

@test 'init_startup_stdlib() sets STARTUP_SCRIPT_STDLIB_INITIALIZED=1 initially' {
  stdlib::init
  assert_equal "$STARTUP_SCRIPT_STDLIB_INITIALIZED" '1'
}

@test 'stdlib::init() takes no action with multiple calls.' {
  stdlib::init
  run stdlib::init # capture output for assertion
  assert_success
  assert_output --regexp 'already initialized, no action taken'
}

@test 'stdlib::init() initializes global variables' {
  stdlib::init
  assert_equal "${PROG}" 'startup-script-stdlib'
}
