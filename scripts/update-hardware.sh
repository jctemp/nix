#!/usr/bin/env bash

set -o errexit  # Exit on error
set -o nounset  # Exit on unset variables
set -o pipefail # Exit on pipe failures

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

# shellcheck source=./lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"
# shellcheck source=./lib/nix-utils.sh
source "${SCRIPT_DIR}/lib/nix-utils.sh"

setup_error_trap on_error

# ==============================================================================
# Script arguments

flake_uri="" # Will be parsed into path and host_name
VERBOSE=0    # Default to non-verbose mode

# ==============================================================================
# CLI parsing
print_usage() {
	cat <<EOF
$(basename "${BASH_SOURCE[0]}") - Update hardware configuration for a NixOS system

USAGE:
  $(basename "${BASH_SOURCE[0]}") --flake <flake_uri> [OPTIONS]

OPTIONS:
  -f, --flake FLAKE_URI   Flake URI pointing to the configuration (e.g., '.#desktop' or '/path/to/config#laptop')
                          (The script will look for ./system/hosts/<host_name>/ within the path part of the URI)
  -v, --verbose           Print verbose output
  -h, --help              Print this help message

EXAMPLES:
  $(basename "${BASH_SOURCE[0]}") --flake .#desktop
  $(basename "${BASH_SOURCE[0]}") --flake /path/to/my/nixconfig#laptop
EOF
}

while [[ $# -gt 0 ]]; do
	case "$1" in
	-f | --flake)
		if [[ $# -gt 1 ]]; then
			flake_uri="$2"
			shift 2
		else
			log_error "Missing value for $1"
			print_usage
			exit 1
		fi
		;;
	-v | --verbose)
		VERBOSE=1
		log_debug "Verbose mode enabled."
		shift
		;;
	-h | --help)
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

# ==============================================================================
# Validate
if [[ -z "${flake_uri}" ]]; then
	log_error "Flake URI is required (use -f or --flake)."
	print_usage
	exit 10
fi

config_root_path=$(cut -d# -f1 <<<"$flake_uri")
host_name=$(cut -d# -f2 <<<"$flake_uri")

if [[ -z "${host_name}" ]] || [[ "${flake_uri}" != *"#"* ]]; then
	log_error "Invalid flake URI format. Expected 'path#name' (e.g., '.#myhost' or '/path/to/flakes#myhost')."
	print_usage
	exit 11
fi

if [[ -z "${config_root_path}" ]] && [[ "${flake_uri}" == "#${host_name}" ]]; then
	config_root_path="."
fi

if [[ ! -d "${config_root_path}" ]]; then
	log_error "Configuration root path '${config_root_path}' (derived from flake URI) does not exist."
	print_usage
	exit 12
fi

# ==============================================================================
# Main
log_info "Starting hardware configuration update for host: ${host_name} (from flake: ${flake_uri})"

host_config_dir="${config_root_path}/system/hosts/${host_name}"
target_facter_file="${host_config_dir}/facter.json"

log_debug "Parsed Flake URI: ${flake_uri}"
log_debug "  Config root path: ${config_root_path}"
log_debug "  Host name: ${host_name}"
log_debug "Target host configuration directory: ${host_config_dir}"
log_debug "Target facter.json file: ${target_facter_file}"

if [[ ! -d "$host_config_dir" ]]; then
	log_error "Target host does not exist: ${host_name}"
	exit 1
fi

if [[ -f "$target_facter_file" ]]; then
	backup_file_name="facter.json.backup-$(date +%Y%m%d%H%M%S)"
	backup_path="${host_config_dir}/${backup_file_name}"
	log_info "Backing up existing '${target_facter_file}' to '${backup_path}'"
	cp "$target_facter_file" "$backup_path" || {
		log_error "Failed to backup facter.json"
		exit 1
	}
fi

log_info "Generating hardware configuration into '${target_facter_file}'"
facter "${host_config_dir}"

log_success "Hardware configuration updated successfully at '${target_facter_file}'"
