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

# Read the project metadata key named "sudoers" and add each comma separated value to
# the sudoers file.
stdlib::setup_sudoers() {
  local user user_list sudoers_file
  user_list="$(stdlib::metadata_get -k 'project/attributes/sudoers')"

  if [[ -z "${user_list}" ]]; then
    stdlib::debug "Skipping sudoers setup.  \
                   The value of the project metadata key named sudoers is empty. \
                   Set sudoers to a comma separated list to enable sudo \
                   support, e.g. sudoers=jmccune,pames"
    return 0
  fi

  sudoers_file="/etc/sudoers"
  sudoers_d="/etc/sudoers.d"

  for user in ${user_list//,/ }; do
    if [[ -f  "${sudoers_d}/${user}" ]] \
      && ( grep -q "^${user}"'\b' "${sudoers_d}/${user}" ) \
      || (grep -q "^${user}"'\b' "${sudoers_file}")  ; then
      stdlib::debug "User ${user} is already in /etc/sudoers or \
                    /etc/sudoers.d/${user}, taking no action"
    else
      stdlib::info "Adding ${user} to /etc/sudoers.d/${user}"
      echo -e "${user}\tALL= (ALL)\tNOPASSWD: ALL" \
      > "${sudoers_d}/${user}" \
      && chmod 0440 "${sudoers_d}/${user}"
    fi
  done

  if visudo -c ; then
    stdlib::info "sudoers config valid!"
  else
    stdlib::error "sudoers config invalid!"
    return 1
  fi
}
