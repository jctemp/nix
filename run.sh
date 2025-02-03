#!/bin/sh

path_to_configuration="."
configuration_name="kent"
user="root"
address="217.76.60.203"
facter_path="./config/facter.json"

nix run github:nix-community/nixos-anywhere -- \
	--flake "${path_to_configuration}#${configuration_name}" \
	--generate-hardware-config nixos-facter "${facter_path}" \
	--phases "kexec,disko" \
	--target-host "${user}@${address}"

