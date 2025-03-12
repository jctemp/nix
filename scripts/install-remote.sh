#!/usr/bin/env bash
# install-remote.sh: Install NixOS configuration on a remote machine

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
ssh_user="root"        # Default value
ssh_address=""         # Required
ssh_port="22"          # Default value
VERBOSE=0              # Default to non-verbose mode

# ---- Usage information ----
print_usage() {
  cat << EOF
$(basename "${BASH_SOURCE[0]}") - Install NixOS configuration on a remote machine

USAGE:
  $(basename "${BASH_SOURCE[0]}") [OPTIONS]

OPTIONS:
  -p, --path PATH         Configuration path (default: ".")
  -n, --name NAME         Configuration name (required)
  -u, --user USER         SSH user (default: "root")
  -a, --address ADDRESS   SSH address (required)
  --port PORT             SSH port (default: "22")
  -v, --verbose           Print verbose output
  -h, --help              Print this help message

EXAMPLES:
  $(basename "${BASH_SOURCE[0]}") --name desktop --address 192.168.1.100
  $(basename "${BASH_SOURCE[0]}") --path /path/to/config --name vm --user admin --address example.com --port 2222
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
  
  # Validate SSH address
  if [[ -z "${ssh_address:-}" ]]; then
    errors+=("SSH address is required (use -a or --address)")
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
  log_info "Starting remote NixOS installation"
  
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
      -u|--user)
        if [[ $# -gt 1 ]]; then
          ssh_user="$2"
          log_debug "Set SSH user: $ssh_user"
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

  # Build paths
  local flake_uri="${configuration_path}#${configuration_name}"
  local facter_path="./hosts/${configuration_name}/facter.json"
  
  log_debug "Configuration path: ${configuration_path}"
  log_debug "Configuration name: ${configuration_name}"
  log_debug "SSH user: ${ssh_user}"
  log_debug "SSH address: ${ssh_address}"
  log_debug "SSH port: ${ssh_port}"
  log_debug "Flake URI: ${flake_uri}"
  log_debug "Facter path: ${facter_path}"

  # Confirm installation to avoid accidents
  if ! confirm_action "This will install NixOS on the remote system at ${ssh_address}. Continue?"; then
    log_info "Installation cancelled by user"
    exit 0
  fi

  # Run nixos-anywhere
  log_info "Installing NixOS on remote system with nixos-anywhere"
  nix run github:nix-community/nixos-anywhere -- \
    --flake "${flake_uri}" \
    --generate-hardware-config nixos-facter "${facter_path}" \
    --target-host "${ssh_user}@${ssh_address}" \
    --ssh-port "${ssh_port}"
    
  local exit_code=$?
  
  if [[ $exit_code -eq 0 ]]; then
    log_success "Remote NixOS installation completed successfully"
  else
    log_error "Remote NixOS installation failed with exit code $exit_code"
    exit $exit_code
  fi
}

# Run the main function
main "$@"
