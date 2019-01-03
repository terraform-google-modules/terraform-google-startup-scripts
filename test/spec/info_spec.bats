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

@test 'stdlib::info() produces output by default' {
  run stdlib::info foo
  assert_success
  assert_output --regexp 'Info \[[0-9]+\]: foo$'
}

@test 'stdlib::info() produces no output when QUIET=1' {
  QUIET=1 run stdlib::info foo
  assert_success
  assert_output ''
}

@test 'stdlib::info() logs to syslog by default' {
  run stdlib::info foo
  assert_success
  assert_syslog '^logger .* -- foo'
}

@test 'stdlib::info() logs to syslog when QUIET=1' {
  QUIET=1 run stdlib::info foo
  assert_success
  assert_syslog '^logger .* -- foo'
}

@test 'stdlib::info() respects the DATE_FMT date format string' {
  DATE_FMT='unix:%s' run stdlib::info foo
  assert_success
  assert_output --regexp '^unix:[0-9]+ Info \[[0-9]+\]: foo' "$output"
}
