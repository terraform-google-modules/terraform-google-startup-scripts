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

# Given a url and filename, download an init script /etc/init.d and setup the init script. This function uses
# stdlib::get_from_bucket which itself uses gsutil to fetch from the bucket.  
#
# This function is intended for single file downloads


# Setup an init script from a GCS Bucket. The URL to the file in the GCS bucket
# is passed as -u, and the file name as -f
# The URL should the full URL pointing to the file 
stdlib::setup_init_script() {
  local OPTIND opt url fname init_script_dir
  while getopts ":u:f:" opt; do
    case "${opt}" in
    u) url="${OPTARG}" ;;
    f) fname="${OPTARG}" ;;
    :)
      stdlib::mandatory_argument -n stdlib::setup_init_script -f "$OPTARG"
      return "${E_MISSING_MANDATORY_ARG}"
      ;;
    *)
      stdlib::error 'Usage: stdlib::setup_init_script -u <url> -f <file name>'
      return "${E_UNKNOWN_ARG}"
      ;;
    esac
  done

  # Trivially compute the filename from the URL if unspecified.
  if [[ -z "${fname}" ]]; then
    fname=${url##*/}
    stdlib::debug "Computed init_script filename='${fname}' given URL."
  fi

  init_script_dir="$(mktemp -d)"
  stdlib::get_from_bucket -u "${url}" -d "${init_script_dir}"
  stdlib::info 'Called stdlib::get_from_bucket' 
  stdlib::cmd install -o 0 -g 0 -m 0755 "${init_script_dir}/${fname}" "/etc/init.d/${fname}"
  stdlib::info 'Installed init script' 
  stdlib::cmd chkconfig --level 2345 "${fname}" on
  stdlib::info 'Setup run levels for init script'
}
