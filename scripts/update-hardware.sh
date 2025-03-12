#!/usr/bin/env bash
# update-hardware.sh: Update hardware configuration for a NixOS system

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
VERBOSE=0              # Default to non-verbose mode

# ---- Usage information ----
print_usage() {
  cat << EOF
$(basename "${BASH_SOURCE[0]}") - Update hardware configuration for a NixOS system

USAGE:
  $(basename "${BASH_SOURCE[0]}") [OPTIONS]

OPTIONS:
  -p, --path PATH         Configuration path (default: ".")
  -n, --name NAME         Configuration name (required)
  -v, --verbose           Print verbose output
  -h, --help              Print this help message

EXAMPLES:
  $(basename "${BASH_SOURCE[0]}") --name desktop
  $(basename "${BASH_SOURCE[0]}") --path /path/to/config --name laptop
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
  log_info "Starting hardware configuration update"
  
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
  local facter_path="${configuration_path}/hosts/${configuration_name}/facter.json"
  
  log_debug "Configuration path: ${configuration_path}"
  log_debug "Configuration name: ${configuration_name}"
  log_debug "Facter path: ${facter_path}"

  # Create host directory if it doesn't exist
  local host_dir="${configuration_path}/hosts/${configuration_name}"
  if [[ ! -d "$host_dir" ]]; then
    log_info "Creating host directory: ${host_dir}"
    mkdir -p "$host_dir"
  fi

  # Backup existing facter.json if it exists
  if [[ -f "$facter_path" ]]; then
    local backup_path="${facter_path}.backup-$(date +%Y%m%d%H%M%S)"
    log_info "Backing up existing facter.json to ${backup_path}"
    cp "$facter_path" "$backup_path"
  fi

  # Generate hardware configuration JSON
  log_info "Generating hardware configuration with nixos-facter"
  nix run \
    --experimental-features "nix-command flakes" \
    nixpkgs#nixos-facter -- -o "${facter_path}"
    
  log_success "Hardware configuration updated successfully at ${facter_path}"
}

# Run the main function
main "$@"
