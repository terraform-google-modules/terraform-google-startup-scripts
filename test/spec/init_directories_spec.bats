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

# Override test_helper setup()
setup() {
  source_stdlib
  MY_VARDIR="$(bats_mktemp -d)/startup"
}

# Use short options to support Mac OS X and Linux.  GNU options break Mac OS X
@test 'stdlib::init_directories() creates $VARDIR using install -d -m 0755 -o 0 -g 0' {
  VARDIR="$MY_VARDIR" run stdlib::init_directories
  assert_install "^install -d -m 0755 -o 0 -g 0 ${MY_VARDIR}"
}

@test 'stdlib::init_directories() does not modify an already existing directory' {
  VARDIR="$(bats_mktemp -d)" run stdlib::init_directories
  assert_no_install
}
