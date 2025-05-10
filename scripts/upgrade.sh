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

flake_uri=""
ssh_target="" # Stores user@address for remote deployment
ssh_port="22" # Default SSH port
VERBOSE=0     # Default to non-verbose mode

# ==============================================================================
print_usage() {
	cat <<EOF
$(basename "${BASH_SOURCE[0]}") - Upgrade NixOS configuration locally or remotely

USAGE:
  $(basename "${BASH_SOURCE[0]}") --flake <flake_uri> [OPTIONS]

OPTIONS:
  -f, --flake FLAKE_URI       Flake URI pointing to the configuration (e.g., '.#desktop' or '/path/to/config#laptop')
  -t, --ssh-target TARGET     Remote target for deployment in 'user@address' format (e.g., root@192.168.1.100)
  --ssh-port PORT             SSH port for remote deployment (default: "22")
  -v, --verbose               Print verbose output
  -h, --help                  Print this help message

EXAMPLES:
  # Local upgrade
  $(basename "${BASH_SOURCE[0]}") --flake .#desktop

  # Remote upgrade
  $(basename "${BASH_SOURCE[0]}") --flake .#server --ssh-target root@192.168.1.100
  $(basename "${BASH_SOURCE[0]}") --flake .#remotevm --ssh-target admin@my.server.com --ssh-port 2222
EOF
}

while [[ $# -gt 0 ]]; do
	case "$1" in
	-f | --flake)
		if [[ $# -gt 1 ]]; then
			flake_uri="$2"
			shift 2
		else
			log_error "Missing value for --flake option."
			print_usage
			exit 1
		fi
		;;
	-t | --ssh-target)
		if [[ $# -gt 1 ]]; then
			ssh_target="$2"
			shift 2
		else
			log_error "Missing value for --ssh-target option."
			print_usage
			exit 1
		fi
		;;
	--ssh-port)
		if [[ $# -gt 1 ]]; then
			ssh_port="$2"
			shift 2
		else
			log_error "Missing value for --ssh-port option."
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

if [[ -z "${flake_uri}" ]]; then
	log_error "Flake URI is required (use -f or --flake)."
	print_usage
	exit 10
fi

# Basic validation for flake URI format (must contain '#')
if [[ "${flake_uri}" != *"#"* ]]; then
	log_error "Invalid flake URI format. Expected 'path#name' (e.g., '.#myhost' or '/path/to/flakes#myhost')."
	print_usage
	exit 11
fi

# If --ssh-port is specified (and not default), --ssh-target must also be provided.
if [[ "${ssh_port}" != "22" && -z "${ssh_target}" ]]; then
	log_error "Remote target (--ssh-target) is required when specifying a non-default --ssh-port."
	print_usage
	exit 12
fi

# ==============================================================================

log_info "Starting NixOS upgrade for flake: ${flake_uri}"

nixos_rebuild_args=(
	"switch"
	"--no-write-lock-file"
	"--flake"
	"${flake_uri}"
)

if [[ ${VERBOSE} -eq 1 ]]; then
	nixos_rebuild_args+=("--verbose" "--show-trace")
fi

if [[ -n "${ssh_target}" ]]; then
	# ---- REMOTE UPGRADE ----
	log_info "Performing remote upgrade on ${ssh_target} (Port: ${ssh_port})"
	log_debug "Target host specification for nixos-rebuild: ${ssh_target}"
	log_debug "Using SSH port: ${ssh_port}"

	nixos_rebuild_args+=("--target-host" "${ssh_target}")

	if [[ "${ssh_port}" != "22" ]]; then
		log_info "Attempting to use non-standard SSH port ${ssh_port}. Ensure SSH client is configured or NIX_SSHOPTS is effective."
	fi

	log_info "Executing: NIX_SSHOPTS=\"-p ${ssh_port}\" nixos-rebuild ${nixos_rebuild_args[*]}"
	NIX_SSHOPTS="-p ${ssh_port}" nixos-rebuild "${nixos_rebuild_args[@]}"

else
	log_info "Executing: nixos-rebuild ${nixos_rebuild_args[*]}"
	sudo nixos-rebuild "${nixos_rebuild_args[@]}"
fi

log_success "System upgrade completed successfully for ${flake_uri}."
