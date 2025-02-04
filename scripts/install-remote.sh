#!/usr/bin/env bash

# TODO: create cmd interface

# Target configuration options
path_to_configuration="."
configuration_name="kent"
facter_path="./config/hosts/${configuration_name}/facter.json"

# SSH options
user="root"
address=""
port="22"

nix run github:nix-community/nixos-anywhere -- \
	--flake "${path_to_configuration}#${configuration_name}" \
	--generate-hardware-config nixos-facter "${facter_path}" \
	--target-host "${user}@${address}" \
	--ssh-port "${port}"
	

