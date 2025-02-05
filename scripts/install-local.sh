#!/usr/bin/env bash

set -o errexit  # Exit on error
set -o nounset  # Exit on unset variables
set -o pipefail # Exit on pipe failures

# shellcheck source=/dev/null
source ./argument_parser.sh
# shellcheck source=/dev/null
source ./logging.sh

### CLI

## OPTIONS
configuration_path="." # Optional
configuration_name="" # Required

print_usage() {
    cat << EOF
Usage: $(basename "${BASH_SOURCE[0]}") [options]

Options:
    -p, --path PATH         Configuration path (default: ".")
    -n, --name NAME         Configuration name (required)
    -v, --verbose           Print verbose output (debug logs)
    -h, --help              Print this help message

Example:
    $(basename "${BASH_SOURCE[0]}") --name kent --address example.com
EOF
}

cli_debug "Starting argument parsing"
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--path)
            parse_argument "configuration_path" "$2"
            cli_debug "Set configuration path: $configuration_path"
            shift 2
            ;;
        -n|--name)
            parse_argument "configuration_name" "$2"
            cli_debug "Set configuration name: $configuration_name"
            shift 2
            ;;
        -v|--verbose)
            # variable is used in cli_debug function
            # shellcheck disable=2034
            VERBOSE=1
            shift 1
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            cli_error "Unknown option $1"
            print_usage
            exit 1
            ;;
    esac
done

cli_debug "Starting parameter validation"
validation_errors=()

if [ -z "$configuration_name" ]; then
    validation_errors+=("Configuration name is required (use -n or --name)")
fi

if [ ! -d "$configuration_path" ]; then
    validation_errors+=("Configuration path '$configuration_path' does not exist")
fi

if [ ${#validation_errors[@]} -ne 0 ]; then
    cli_error "Incorrect or missing arguments"
    for error in "${validation_errors[@]}"; do
        cli_error "  $error"
    done
    echo
    print_usage
    exit 1
fi

cli_info "Arguments validated successfully"
cli_debug "Final arguments:"
cli_debug "| CONFIGURATION"
cli_debug "  | Path:    $configuration_path"
cli_debug "  | Name:    $configuration_name"


## SCRIPT
cli_debug "Building paths"
facter_path="./config/hosts/${configuration_name}/facter.json"
flake_path="${configuration_path}#${configuration_name}"
cli_debug "  facter_path=${facter_path}"
cli_debug "  flake_path=${flake_path}"

cli_debug "Generating hardware configuration json"
nix run \
  --experimental-features "nix-command flakes" \
  nixpkgs#nixos-facter -- -o "${facter_path}"

cli_debug "Run disko partitioning"
nix run \
  --experimental-features "nix-command flakes" \
  nixpkgs#disko -- --mode disko --flake "${flake_path}"

cli_debug "Installing system"
nixos-install -v --show-trace --no-root-passwd\
  --flake "${flake_path}" 

cli_debug "Finalising changes"
cd /
umount -Rl "/mnt"
zpool export -a

# reboot
cli_success "You can now run 'reboot'"
