#!/usr/bin/env bash
# upgrade.sh: Upgrade NixOS configuration locally or remotely

set -o errexit  # Exit on error
set -o nounset  # Exit on unset variables
set -o pipefail # Exit on pipe failures

# Get script directory for loading dependencies
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

# Load common functions
# shellcheck source=./common-functions.sh
source "${SCRIPT_DIR}/common-functions.sh"

# ---- Script configuration ----
configuration_path="." # Default value
configuration_name=""  # Required
ssh_address=""         # Optional
ssh_port="22"          # Default value
is_remote=false        # Default to local
VERBOSE=0              # Default to non-verbose mode

# ---- Usage information ----
print_usage() {
  cat << EOF
$(basename "${BASH_SOURCE[0]}") - Upgrade NixOS configuration locally or remotely

USAGE:
  $(basename "${BASH_SOURCE[0]}") [OPTIONS]

OPTIONS:
  -p, --path PATH         Configuration path (default: ".")
  -n, --name NAME         Configuration name (required)
  -a, --address ADDRESS   SSH address for remote deployment (optional)
  --port PORT             SSH port (default: "22", only used with --address)
  -v, --verbose           Print verbose output
  -h, --help              Print this help message

EXAMPLES:
  # Local upgrade
  $(basename "${BASH_SOURCE[0]}") --name desktop
  
  # Remote upgrade
  $(basename "${BASH_SOURCE[0]}") --name vm --address 192.168.1.100
EOF
}

# Function to validate arguments
validate_args() {
  local -a errors=()

  # Validate required configuration_name
  if [[ -z "${configuration_name:-}" ]]; then
    errors+=("Configuration name is required (use -n or --name)")
  fi

  # Check configuration path exists if specified
  if [[ -n "${configuration_path:-}" ]] && [[ ! -d "${configuration_path}" ]]; then
    errors+=("Configuration path '${configuration_path}' does not exist")
  fi

  # Report errors if any
  if [[ ${#errors[@]} -gt 0 ]]; then
    log_error "Missing or invalid arguments:"
    for error in "${errors[@]}"; do
      log_error "  - $error"
    done
    return 1
  fi

  return 0
}

# Main function
main() {
  log_info "Starting NixOS upgrade"
  
  # Parse command line arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -p|--path)
        if [[ $# -gt 1 ]]; then
          configuration_path="$2"
          log_debug "Set configuration path: $configuration_path"
          shift 2
        else
          log_error "Missing value for $1"
          print_usage
          exit 1
        fi
        ;;
      -n|--name)
        if [[ $# -gt 1 ]]; then
          configuration_name="$2"
          log_debug "Set configuration name: $configuration_name"
          shift 2
        else
          log_error "Missing value for $1"
          print_usage
          exit 1
        fi
        ;;
      -a|--address)
        if [[ $# -gt 1 ]]; then
          ssh_address="$2"
          is_remote=true
          log_debug "Set SSH address: $ssh_address"
          shift 2
        else
          log_error "Missing value for $1"
          print_usage
          exit 1
        fi
        ;;
      --port)
        if [[ $# -gt 1 ]]; then
          ssh_port="$2"
          log_debug "Set SSH port: $ssh_port"
          shift 2
        else
          log_error "Missing value for $1"
          print_usage
          exit 1
        fi
        ;;
      -v|--verbose)
        VERBOSE=1
        log_debug "Verbose mode enabled"
        shift
        ;;
      -h|--help)
        print_usage
        exit 0
        ;;
      *)
        log_error "Unknown option: $1"
        print_usage
        exit 1
        ;;
    esac
  done

  # Validate required arguments
  validate_args || { print_usage; exit 1; }

  # Build flake URI
  local flake_uri="${configuration_path}#${configuration_name}"
  
  log_debug "Configuration path: ${configuration_path}"
  log_debug "Configuration name: ${configuration_name}"
  log_debug "Flake URI: ${flake_uri}"
  
  if $is_remote; then
    log_debug "Remote upgrade: ${ssh_address}:${ssh_port}"
  else
    log_debug "Local upgrade"
    # Check for root only for local upgrades
    check_root
  fi

  # Perform system upgrade
  if $is_remote; then
    log_info "Upgrading remote system at ${ssh_address}"
    nixos-rebuild switch \
      --no-write-lock-file \
      --verbose \
      --flake "${flake_uri}" \
      --target-host "root@${ssh_address}:${ssh_port}"
  else
    log_info "Upgrading local system"
    nixos-rebuild switch \
      --no-write-lock-file \
      --verbose \
      --flake "${flake_uri}"
  fi

  log_success "System upgrade completed successfully"
}

# Run the main function
main "$@"
