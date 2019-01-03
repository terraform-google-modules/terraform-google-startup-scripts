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

@test 'stdlib::cmd(echo foo) is successful' {
  run stdlib::cmd echo foo
  assert_success
  assert_output 'foo'
}

@test 'stdlib::cmd(false) is unsuccessful' {
  run stdlib::cmd false
  assert_failure
}

@test 'stdlib::cmd() logs BEGIN, END, and exit_code via debug' {
  DEBUG=1 run stdlib::cmd echo foo
  assert_success
  assert_output --regexp 'BEGIN: stdlib::cmd.* command=.echo foo.'
  assert_output --regexp 'END: stdlib::cmd.* command=.echo foo. exit_code=0'
}
