#!/bin/sh

# Error Codes
MNT_NOT_SET=1
HOST_NOT_SET=2
REPO_NOT_SET=3

# ------------------ Input Validation ------------------------------

if [ -z "${MNT}" ]; then
    echo "Error: MNT is not set."
    exit $MNT_NOT_SET
fi

if [ -z "${HOST}" ]; then
    echo "Error: HOST is no set."
    exit $HOST_NOT_SET
fi

if [ -z "${REPO}" ]; then
    echo "Error: HOST is no set."
    exit $REPO_NOT_SET
fi

# ------------------ Nix file configuration ------------------------------

local="${MNT}/etc"
safe="${MNT}/persist/etc"

mkdir -p "${safe}"
git clone "${REPO}" "${safe}/nixos"

file="${safe}/nixos/machines/${HOST}/hardware-configuration.nix"

if [ ! -f "$file" ]; then
    touch $file
fi

nixos-generate-config --root "${MNT}" --show-hardware-config |
    tee $file >/dev/null

cp -R "${safe}/nixos" "${local}"

nixos-install --root "${MNT}" \
    --no-root-passwd \
    --flake "${safe}/nixos#${HOST}"
