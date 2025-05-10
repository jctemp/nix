#!/usr/bin/env bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CLEAR='\033[0m'

log_info() {
    echo -e "[${BLUE}INFO${CLEAR}] $1"
}

log_success() {
    echo -e "[${GREEN}SUCCESS${CLEAR}] $1"
}

log_warn() {
    echo -e "[${YELLOW}WARNING${CLEAR}] $1"
}

log_error() {
    echo -e "[${RED}ERROR${CLEAR}] $1" >&2
}

log_debug() {
    if [[ ${VERBOSE:-0} -eq 1 ]]; then
        echo -e "[${BLUE}DEBUG${CLEAR}] $1"
    fi
}

on_error() {
    log_error "An error occurred at line ${BASH_LINENO[0]} in command: ${BASH_COMMAND}"
    exit 1
}

setup_error_trap() {
    # Function to be called on error
    local trap_func=${1:-on_error}
    trap '${trap_func}' ERR
}

confirm_action() {
    local prompt=${1:-"Continue?"}
    read -r -p "$prompt [y/N] " response
    [[ "$response" =~ ^[Yy] ]]
}
