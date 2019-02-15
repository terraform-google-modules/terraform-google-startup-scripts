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

# Setup an init script from metadata.  The name of the init script is passed as
# -n, the metadata key as -k
stdlib::setup_init_script() {
  local OPTIND opt name key init_script
  while getopts ":n:k:" opt; do
    case "${opt}" in
    n) name="${OPTARG}" ;;
    k) key="${OPTARG}" ;;
    :)
      stdlib::mandatory_argument -n stdlib::setup_init_script -f "$OPTARG"
      return "${E_MISSING_MANDATORY_ARG}"
      ;;
    *)
      stdlib::error 'Usage -n <name> -k <metadata-key>'
      return "${E_UNKNOWN_ARG}"
      ;;
    esac
  done
  init_script="$(mktemp)"
  stdlib::metadata_get -k "instance/attributes/${key}" >"${init_script}"
  stdlib::cmd install -o 0 -g 0 -m 0755 "${init_script}" "/etc/init.d/${name}"
  stdlib::cmd chkconfig --level 2345 "${name}" on
}
