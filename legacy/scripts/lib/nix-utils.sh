#!/usr/bin/env bash

_UTILS_DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
# shellcheck source=./common.sh
source "${_UTILS_DIR}/common.sh"

nixstall() {
	if [ $# -ne 1 ]; then
		log_error "nixstall: Requires the flake URI as an argument."
		exit 1
	fi

	sudo nixos-install --verbose \
		--show-trace \
		--no-root-passwd \
		--flake "${1}"
}

disko() {
	if [ $# -ne 1 ]; then
		log_error "disko: Requires the flake URI as an argument."
		exit 1
	fi

	sudo nix run --experimental-features "nix-command flakes" \
		nixpkgs#disko -- \
		--debug \
		--mode destroy,format,mount \
		--flake "${1}"
}

facter() {
	if [ $# -ne 1 ]; then
		log_error "facter: Requires a target directory as an argument."
		exit 1
	fi

	if [ ! -d "${1}" ]; then
		log_error "facter: Provided argument '${1}' is not a directory."
		exit 1
	fi

	sudo nix run --experimental-features "nix-command flakes" \
		nixpkgs#nixos-facter -- \
		-o "${1}/facter.json"
}

anywhere() {
	if [ $# -ne 4 ]; then
		log_error "anywhere: Argument incomplete. Expected 4, got $#."
		cat <<EOF
Usage: anywhere <FLAKE_URI> <FACTER_JSON_PATH> <SSH_TARGET_HOST> <SSH_PORT>
Example: anywhere .#myconfig ./path/to/facter.json root@somehost 22
EOF
		exit 1
	fi

	if [ ! -f "${2}" ]; then
		log_error "anywhere: Facter JSON path '${2}' does not exist or is not a regular file."
		exit 1
	fi

	nix run github:nix-community/nixos-anywhere -- \
		--flake "${1}" \
		--generate-hardware-config nixos-facter "${2}" \
		--target-host "${3}" \
		--ssh-port "${4}"
}
