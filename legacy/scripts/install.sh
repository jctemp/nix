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

# --flake, -f
flake_uri=""
# --ssh-target, -s
ssh_target=""
# --ssh-port, -p
ssh_port="22"
# --hardware-config, -c
hardware_config="0"
# --verbose, -v
VERBOSE=0

# ==============================================================================
# CLI parsing

print_usage() {
	cat <<EOF
$(basename "${BASH_SOURCE[0]}") - Install NixOS configuration on any machine

USAGE:
  $(basename "${BASH_SOURCE[0]}") [OPTIONS]

OPTIONS:
  -f, --flake FLAKE           flake_uri (expects: path#name)
  -t, --ssh-target HOST       ssh_target (expects: user@address)
  -p, --ssh-port PORT         ssh_port (default: 22)
  -c, --hardware-config       Generate hardware configuration (default: false)
  -v, --verbose               Print verbose output (default: false)
  -h, --help                  Print this help message

EXAMPLES:
  # Local install (no --ssh-host)
  $(basename "${BASH_SOURCE[0]}") --flake .#desktop

  # Remote install
  $(basename "${BASH_SOURCE[0]}") --flake .#server --ssh-target root@remote.example.com
  $(basename "${BASH_SOURCE[0]}") --flake /path/to/config#vm \\
    --ssh-target admin@example.com --ssh-port 2222
EOF
}

while [[ $# -gt 0 ]]; do
	case "${1}" in
	-f | --flake)
		flake_uri="${2}"
		shift 2
		;;
	-t | --ssh-target)
		ssh_target="${2}"
		shift 2
		;;
	-p | --ssh-port)
		ssh_port="${2}"
		shift 2
		;;
	-c | --hardware-config)
		hardware_config=1
		shift 1
		;;
	-v | --verbose)
		VERBOSE=1
		log_debug "Verbose mode enabled."
		shift 1
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

if [ -z "${flake_uri}" ]; then
	log_error "Flake URI (--flake) is required."
	print_usage
	exit 10
fi

host_config_name=$(cut -d# -f2 <<<"$flake_uri")
if [ -z "$host_config_name" ] || [[ "$flake_uri" != *"#"* ]]; then
	log_error "Invalid flake URI format. Expected 'path#name' (e.g., .#myhost or /path/to/flakes#myhost)."
	print_usage
	exit 11
fi

facter_path="./system/hosts/${host_config_name}"

log_debug "  flake_uri: ${flake_uri}"
log_debug " ssh_target: ${ssh_target}"
log_debug "   ssh_port: ${ssh_port}"
log_debug "facter_path: ${facter_path}"

# ==============================================================================
# Main

if [ -n "${ssh_target}" ]; then
	log_info "Starting remote NixOS installation for ${flake_uri} on ${ssh_target}"
	if [ ! -d "$facter_path" ]; then
		facter_path="."
	fi
	anywhere "${flake_uri}" "${facter_path}/facter.json" "${ssh_target}" "${ssh_port}"
	log_success "Remote installation completed for ${flake_uri} on ${ssh_target}"
else
	log_info "Starting local NixOS installation for ${flake_uri}"

	if [ "$hardware_config" -eq 1 ]; then
		log_info "Generating hardware configuration into ${facter_path}/facter.json"
		if [ ! -d "$facter_path" ]; then
			log_error "Facter path does not exist. Please run the script in config root"
			exit 12
		fi
		facter "${facter_path}"
	else
		log_info "Skipping hardware configuration generation."
		if [ ! -f "${facter_path}/facter.json" ]; then
			log_warn "Hardware configuration generation skipped and '${facter_path}/facter.json' not found."
			log_warn "Ensure your NixOS configuration for '${host_config_name}' does not rely on it or provides it another way."
		fi
	fi

	log_info "Running disk partitioning with disko for ${flake_uri}"
	disko "${flake_uri}"

	log_info "Installing NixOS system with flake ${flake_uri}"
	nixstall "${flake_uri}"

	log_info "Finalizing installation"
	cd /
	umount -Rl "/mnt"
	zpool export -a

	log_success "Installation completed successfully"
	if confirm_action "Would you like to reboot now?"; then
		log_info "Rebooting system..."
		reboot
	else
		log_info "You can reboot manually when ready using the 'reboot' command"
	fi
fi
