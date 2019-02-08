#! /bin/bash
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

# Install the compiled version of crcmod to get faster checksums when
# transferring objects from GCS.  This function is intended for Enterprise Linux
# flavor operating systems.  See:
# https://cloud.google.com/storage/docs/gsutil/addlhelp/CRC32CandInstallingcrcmod
stdlib::init_gsutil_crcmod_el() {
  if gsutil version -l | grep -qix 'compiled crcmod: True'; then
    stdlib::debug "Skipping init_gsutil_crcmod_el() because gsutil version -l reports compiled crcmod: True"
    return 0
  fi
  # Install dependencies
  stdlib::info "gsutil -version -l reports compiled crcmod is not true"
  stdlib::info "BEGIN: gsutil crcmod compilation and installation"
  stdlib::cmd yum -y install gcc python-devel python-setuptools redhat-rpm-config
  # Use the correct python version in a subshell to avoid pollution of the
  # calling environment.
  (
    set +u # avoid MANPATH unbound variable issue.
    eval "$(grep -m1 'source .*/enable' /usr/bin/gsutil)"
    stdlib::cmd easy_install -U pip
    stdlib::cmd pip uninstall crcmod
    stdlib::cmd pip install -U crcmod
  )
  stdlib::info "END: gsutil crcmod compilation and installation"
}
