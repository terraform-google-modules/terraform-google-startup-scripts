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

# Standard library of functions useful for startup scripts.

# Pending UX behaviors
# TODO(jmccune): load_config_values to load user configuration
# TODO(jmccune): call mandatory_argument() before E_MISSING_MANDATORY_ARG
# TODO(jmccune): add -c <name> for alternate startup-script-custom name
# Pending initialization functions:
# TODO(jmccune): gsutil initialization w/ crcmod
# Pending operational functions:
# TODO(jmccune): get_from_bucket()
# TODO(jmccune): setup_init_script()
# TODO(jmccune): setup_sudoers()

# These are outside init_global_vars so logging functions work with the most
# basic case of `source startup-script-stdlib.sh`
readonly SYSLOG_DEBUG_PRIORITY="${SYSLOG_DEBUG_PRIORITY:-syslog.debug}"
readonly SYSLOG_INFO_PRIORITY="${SYSLOG_INFO_PRIORITY:-syslog.info}"
readonly SYSLOG_ERROR_PRIORITY="${SYSLOG_ERROR_PRIORITY:-syslog.error}"
# Global counter of how many times stdlib::init() has been called.
STARTUP_SCRIPT_STDLIB_INITIALIZED=0

# Error codes
readonly E_RUN_OR_DIE=5
readonly E_MISSING_MANDATORY_ARG=9
readonly E_UNKNOWN_ARG=10

stdlib::debug() {
  [[ -z "${DEBUG:-}" ]] && return 0
  local ds msg
  msg="$*"
  logger -p "${SYSLOG_DEBUG_PRIORITY}" -t "${PROG}[$$]" -- "${msg}"
  [[ -n "${QUIET:-}" ]] && return 0
  ds="$(date +"${DATE_FMT}") "
  echo -e "${BLUE}${ds}Debug [$$]: ${msg}${NC}" >&2
}

stdlib::info() {
  local ds msg
  msg="$*"
  logger -p "${SYSLOG_INFO_PRIORITY}" -t "${PROG}[$$]" -- "${msg}"
  [[ -n "${QUIET:-}" ]] && return 0
  ds="$(date +"${DATE_FMT}") "
  echo -e "${GREEN}${ds}Info [$$]: ${msg}${NC}" >&2
}

stdlib::error() {
  local ds msg
  msg="$*"
  ds="$(date +"${DATE_FMT}") "
  logger -p "${SYSLOG_ERROR_PRIORITY}" -t "${PROG}[$$]" -- "${msg}"
  echo -e "${RED}${ds}Error [$$]: ${msg}${NC}" >&2
}

# The main initialization function of this library.  This should be kept to the
# minimum amount of work required for all functions to operate cleanly.
stdlib::init() {
  if [[ ${STARTUP_SCRIPT_STDLIB_INITIALIZED} -gt 0 ]]; then
    stdlib::info 'stdlib::init()'" already initialized, no action taken."
    return 0
  fi
  ((STARTUP_SCRIPT_STDLIB_INITIALIZED++)) || true
  stdlib::init_global_vars
  stdlib::init_directories
  stdlib::debug "stdlib::init(): startup-script-stdlib.sh initialized and ready"
}

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

# Transfer control to startup-startup-script-custom.  The script is sourced to
# ensure all functions are exposed and the trap handlers configured here are
# fired on exit.  A local file path or http URL are both supported.
stdlib::run_startup_script_custom() {
  local script_file key
  local exit_code
  # shellcheck disable=SC2119
  script_file="$(stdlib::mktemp)"
  key="instance/attributes/startup-script-custom"

  if ! stdlib::metadata_get -k "${key}" -o "${script_file}"; then
    stdlib::error "Could not fetch custom startup script." \
      "Make sure ${key} exists."
    return 1
  fi

  stdlib::debug "=== BEGIN ${key} ==="
  # shellcheck source=/dev/null
  source "${script_file}"
  exit_code=$?
  stdlib::debug "=== END ${key} exit_code=${exit_code} ==="
  return $exit_code
}

# Initialize global variables.
stdlib::init_global_vars() {
  # The program name, used for logging.
  readonly PROG="${PROG:-startup-script-stdlib}"
  # Date format used for stderr logging.  Passed to date + command.
  readonly DATE_FMT="${DATE_FMT:-"%a %b %d %H:%M:%S %z %Y"}"
  # var directory
  readonly VARDIR="${VARDIR:-/var/lib/startup}"
  # Override this with file://localhost/tmp/foo/bar in spec test context
  readonly METADATA_BASE="${METADATA_BASE:-http://metadata.google.internal}"

  # Color variables
  if [[ -n "${COLOR:-}" ]]; then
    readonly NC='\033[0m'        # no color
    readonly RED='\033[0;31m'    # error
    readonly GREEN='\033[0;32m'  # info
    readonly BLUE='\033[0;34m'   # debug
  else
    readonly NC=''
    readonly RED=''
    readonly GREEN=''
    readonly BLUE=''
  fi

  return 0
}

stdlib::init_directories() {
  if ! [[ -e "${VARDIR}" ]]; then
    install -d -m 0755 -o 0 -g 0 "${VARDIR}"
  fi
}

##
# Get a metadata key.  When used without -o, this function is guaranteed to
# produce no output on STDOUT other than the retrieved value.  This is intended
# to support the use case of
# FOO="$(stdlib::metadata_get -k instance/attributes/foo)"
#
# If the requested key does not exist, the error code will be 22 and zero bytes
# written to STDOUT.
stdlib::metadata_get() {
  local OPTIND opt key outfile
  local metadata="${METADATA_BASE%/}/computeMetadata/v1"
  local exit_code
  while getopts ":k:o:" opt; do
    case "${opt}" in
    k) key="${OPTARG}" ;;
    o) outfile="${OPTARG}" ;;
    :)
      stdlib::error "Invalid option: -${OPTARG} requires an argument"
      stdlib::metadata_get_usage
      return "${E_MISSING_MANDATORY_ARG}"
      ;;
    *)
      stdlib::error "Unknown option: -${opt}"
      stdlib::metadata_get_usage
      return "${E_UNKNOWN_ARG}"
      ;;
    esac
  done
  local url="${metadata}/${key#/}"

  stdlib::debug "Getting metadata resource url=${url}"
  if [[ -z "${outfile:-}" ]]; then
    curl --location --silent --connect-timeout 1 --fail \
      -H 'Metadata-Flavor: Google' "$url" 2>/dev/null
    exit_code=$?
  else
    stdlib::cmd curl --location \
      --silent \
      --connect-timeout 1 \
      --fail \
      --output "${outfile}" \
      -H 'Metadata-Flavor: Google' \
      "$url"
    exit_code=$?
  fi
  case "${exit_code}" in
    22 | 37)
      stdlib::debug "curl exit_code=${exit_code} for url=${url}" \
        "(Does not exist)"
      ;;
  esac
  return "${exit_code}"
}

stdlib::metadata_get_usage() {
  stdlib::info 'Usage: stdlib::metadata_get -k <key>'
  stdlib::info 'For example: stdlib::metadata_get -k instance/attributes/startup-config'
}

# Run a command logging the entry and exit.  Intended for system level commands
# and operational debugging.  Not intended for use with redirection.  This is
# not named run() because bats uses a run() function.
stdlib::cmd() {
  local exit_code argv=("$@")
  stdlib::debug "BEGIN: stdlib::cmd() command=[${argv[*]}]"
  "${argv[@]}"
  exit_code=$?
  stdlib::debug "END: stdlib::cmd() command=[${argv[*]}] exit_code=${exit_code}"
  return $exit_code
}

# Run a command successfully or exit the program with an error.
stdlib::run_or_die() {
  if ! stdlib::cmd "$@"; then
    stdlib::error "stdlib::run_or_die(): exiting with exit code ${E_RUN_OR_DIE}."
    exit "${E_RUN_OR_DIE}"
  fi
}

# Intended to take advantage of automatic cleanup of startup script library
# temporary files without exporting a modified TMPDIR to child processes, which
# would cause the children to have their TMPDIR deleted out from under them.
# shellcheck disable=SC2120
stdlib::mktemp() {
  TMPDIR="${DELETE_AT_EXIT:-${TMPDIR}}" mktemp "$@"
}

stdlib::main() {
  DELETE_AT_EXIT="$(mktemp -d)"
  readonly DELETE_AT_EXIT

  # Initialize state required by other functions, e.g. debug()
  stdlib::init
  stdlib::debug "Loaded startup-script-stdlib as an executable."

  # TODO(jmccune): Add configuration behavior
  # stdlib::load_config_values

  stdlib::run_startup_script_custom
}

# if script is being executed and not sourced.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  stdlib::finish() {
    [[ -d "${DELETE_AT_EXIT:-}" ]] && rm -rf "${DELETE_AT_EXIT}"
  }
  trap stdlib::finish EXIT

  stdlib::main "$@"
fi
