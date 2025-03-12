#!/usr/bin/env bash
# common-functions.sh: Shared utility functions for NixOS scripts

# ---- Output formatting ----
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ---- Logging functions ----
log_info() {
  echo -e "[${BLUE}INFO${NC}] $1"
}

log_success() {
  echo -e "[${GREEN}SUCCESS${NC}] $1"
}

log_warn() {
  echo -e "[${YELLOW}WARNING${NC}] $1"
}

log_error() {
  echo -e "[${RED}ERROR${NC}] $1" >&2
}

log_debug() {
  if [[ ${VERBOSE:-0} -eq 1 ]]; then
    echo -e "[${BLUE}DEBUG${NC}] $1"
  fi
}

# ---- Utility functions ----
build_flake_uri() {
  local path="${1:-$configuration_path}"
  local name="${2:-$configuration_name}"
  echo "${path}#${name}"
}

# Function to check if running script as root
check_root() {
  if [[ $EUID -ne 0 ]]; then
    log_error "This script must be run as root"
    exit 1
  fi
}

# Trap for error handling
setup_error_trap() {
  # Function to be called on error
  local trap_func=${1:-on_error}
  
  trap "${trap_func}" ERR
}

# Default error handler
on_error() {
  log_error "An error occurred at line $BASH_LINENO in command: ${BASH_COMMAND}"
  exit 1
}

# Confirm action with user
confirm_action() {
  local prompt=${1:-"Continue?"}
  local default=${2:-"y"}
  
  if [[ "$default" == "y" ]]; then
    read -p "$prompt [Y/n] " response
    [[ -z "$response" || "$response" =~ ^[Yy] ]]
  else
    read -p "$prompt [y/N] " response
    [[ "$response" =~ ^[Yy] ]]
  fi
}
