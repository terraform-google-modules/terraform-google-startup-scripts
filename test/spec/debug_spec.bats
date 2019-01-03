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

@test 'stdlib::debug() produces no output by default' {
  run stdlib::debug foo
  assert_success
  assert_output ''
}

@test 'stdlib::debug() does not log to syslog by default' {
  run stdlib::debug foo
  assert_success
  assert_no_logger
}

@test 'stdlib::debug() logs to syslog when DEBUG is non-zero length' {
  DEBUG=1 run stdlib::debug foo
  assert_success
  assert_syslog '^logger .* -- foo$'
}

@test 'stdlib::debug() produces output when DEBUG is non-zero length' {
  DEBUG=1 run stdlib::debug foo
  assert_success
  assert_output --regexp 'Debug \[[0-9]+\]: foo$'
}

@test 'stdlib::debug() logs to syslog only with DEBUG=1 and QUIET=1' {
  QUIET=1 DEBUG=1 run stdlib::debug foo
  assert_success
  assert_output ''
  assert_syslog '^logger .* -- foo$'
}

@test 'stdlib::debug() respects the DATE_FMT date format string' {
  DATE_FMT='unix:%s' DEBUG=1 run stdlib::debug foo
  assert_success
  assert_output --regexp '^unix:[0-9]+ Debug \[[0-9]+\]: foo' "$output"
}
