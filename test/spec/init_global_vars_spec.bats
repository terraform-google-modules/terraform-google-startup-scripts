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

@test 'stdlib::init_global_vars() runs successfully' {
  run stdlib::init_global_vars
  assert_success
}

@test 'stdlib::init_global_vars() sets PROG=startup-script-stdlib if unset' {
  stdlib::init_global_vars
  assert_equal "$PROG" "startup-script-stdlib"
}

@test 'stdlib::init_global_vars() respects PROG if set' {
  PROG=foo stdlib::init_global_vars
  assert_equal "$PROG" "foo"
}

@test 'stdlib::init_global_vars() sets VARDIR=/var/lib/startup if unset' {
  unset VARDIR
  stdlib::init_global_vars
  assert_equal "$VARDIR" "/var/lib/startup"
}

@test 'stdlib::init_global_vars() respects VARDIR if set' {
  VARDIR='/var/lib/startup-jeff' stdlib::init_global_vars
  assert_equal "$VARDIR" "/var/lib/startup-jeff"
}

@test 'stdlib::init_global_vars() sets RED, GREEN, BLUE when COLOR is non-zero length' {
  COLOR=1 stdlib::init_global_vars
  assert_equal "$RED" '\033[0;31m'    # error
  assert_equal "$GREEN" '\033[0;32m'  # info
  assert_equal "$BLUE" '\033[0;34m'   # debug
}

@test 'stdlib::init_global_vars() unsets RED, GREEN, BLUE when COLOR is zero length' {
  COLOR='' stdlib::init_global_vars
  assert_equal "$RED" ''
  assert_equal "$GREEN" ''
  assert_equal "$BLUE" ''
}

@test 'stdlib::init_global_vars() sets PROG readonly' {
  stdlib::init_global_vars
  status=1
  (PROG=foo) || status=0 # should fail
  assert_success
}

@test 'stdlib::init_global_vars() sets DATE_FMT readonly' {
  stdlib::init_global_vars
  status=1
  (DATE_FMT=foo) || status=0 # should fail
  assert_success
}

@test 'stdlib::init_global_vars() sets VARDIR readonly' {
  stdlib::init_global_vars
  status=1
  (VARDIR=foo) || status=0 # should fail
  assert_success
}

# TODO(jmccune) It may be desirable to override METADATA_BASE Look out for users
# who want this behavior and consider the affordance.
@test 'stdlib::init_global_vars() sets METADATA_BASE readonly' {
  stdlib::init_global_vars
  status=1
  (METADATA_BASE=foo) || status=0 # should fail
  assert_success
}

@test 'stdlib::init_global_vars() sets NC readonly' {
  stdlib::init_global_vars
  status=1
  (NC=foo) || status=0 # should fail
  assert_success
}

@test 'stdlib::init_global_vars() sets RED readonly' {
  stdlib::init_global_vars
  status=1
  (RED=foo) || status=0 # should fail
  assert_success
}

@test 'stdlib::init_global_vars() sets GREEN readonly' {
  stdlib::init_global_vars
  status=1
  (GREEN=foo) || status=0 # should fail
  assert_success
}

@test 'stdlib::init_global_vars() sets BLUE readonly' {
  stdlib::init_global_vars
  status=1
  (BLUE=foo) || status=0 # should fail
  assert_success
}
