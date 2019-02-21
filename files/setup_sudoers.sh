#! /bin/bash
# Read the project metadata key named "sudoers" and add each comma separated value to
# the sudoers file.
stdlib::setup_sudoers() {
  local user user_list sudoers_file
  user_list="$(metadata_get -k 'project/attributes/sudoers')"

  if [[ -z "${user_list}" ]]; then
    stdlib::debug "Skipping sudoers setup.  The value of the project metadata key named sudoers is empty.  Set sudoers to a comma separated list to enable sudo support, e.g. sudoers=jmccune,pames"
    return 0
  fi

  sudoers_file="$(mktemp)"
  cp /etc/sudoers "${sudoers_file}"

  for user in ${user_list//,/ }; do
    if grep -q "^${user}"'\b' "${sudoers_file}"; then
      stdlib::debug "User ${user} is already in /etc/sudoers, taking no action"
    else
      stdlib::info "Adding ${user} to /etc/sudoers"
      echo -e "${user}\tALL= (ALL)\tNOPASSWD: ALL" >>"${sudoers_file}"
    fi
  done

  if cmp --silent /etc/sudoers "${sudoers_file}"; then
    stdlib::debug "No changes necessary to sudoers file, doing nothing."
    return 0
  else
    stdlib::info "Staged changes to sudoers:"
    diff -U2 /etc/sudoers "${sudoers_file}" || true
    if visudo -cf "${sudoers_file}"; then
      stdlib::info "Installing new /etc/sudoers file"
      stdlib::cmd install -o 0 -g 0 -m 0440 "${sudoers_file}" /etc/sudoers
      return $?
    else
      stdlib::error "Skipping modification of /etc/sudoers because the temporary sudoers file is invalid."
      return 1
    fi
  fi
}
