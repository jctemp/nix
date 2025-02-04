#!/usr/bin/env bash

# TODO: create cmd interface
DISKO_CONFIG="./config/disko.nix"

# Configuration options
path_to_configuration="."
configuration_name="kent"
facter_path="./config/hosts/${configuration_name}/facter.json"

# generate facter file
sudo nix run \
  --option experimental-features "nix-command flakes" \
  --option extra-substituters https://numtide.cachix.org \
  --option extra-trusted-public-keys numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE= \
  github:numtide/nixos-facter -- -o "${facter_path}"

# perform disko partitioning
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- \
  --mode destroy,format,mount "${DISKO_CONFIG}"

# install system
nixos-install

# unmount and export
cd /
umount -Rl "/mnt"
zpool export -a

# reboot
reboot
