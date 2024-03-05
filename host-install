#!/usr/bin/env bash

set -euo pipefail

################################################################################

export COLOR_RESET="\033[0m"
export RED_BG="\033[41m"
export BLUE_BG="\033[44m"

function err {
    echo -e "${RED_BG}$1${COLOR_RESET}"
}

function info {
    echo -e "${BLUE_BG}$1${COLOR_RESET}"
}

################################################################################

if [ $# -ne 3 ]; then
    err "install <DISK_PATH> <HOST> <REMOTE>"
fi

if [ ! -b "$1" ]; then
    err "Missing first argument. Expected block device name, e.g. 'sda'"
    exit 1
fi

if [ -z "$2" ]; then
    err "Missing second argument. Expected a host name."
    exit 1
fi

if [ -z "$3" ]; then
    err "Missing third argument. Expected a remote repository."
    exit 1
fi

if [ "$EUID" -ne 0 ]; then
    err "Must run as root"
    exit 1
fi

export DISK_PATH=$1
export HOST=$2
export REMOTE=$3

export RESERVE=32

export ZFS_POOL="rpool"
export ZFS_LOCAL="${ZFS_POOL}/local"
export ZFS_DS_ROOT="${ZFS_LOCAL}/root"
export ZFS_DS_NIX="${ZFS_LOCAL}/nix"

export ZFS_SAFE="${ZFS_POOL}/safe"
export ZFS_DS_HOME="${ZFS_SAFE}/home"
export ZFS_DS_PERSIST="${ZFS_SAFE}/persist"

export ZFS_BLANK_SNAPSHOT="${ZFS_DS_ROOT}@blank"

################################################################################

info "Running the UEFI (GPT) partitioning and formatting directions from the NixOS manual ..."

blkdiscard -f "$DISK_PATH"

parted --script --align=optimal "$DISK_PATH" -- \
    mklabel gpt \
    mkpart EFI 1MiB 4GiB \
    mkpart rpool 4GiB -"${RESERVE}"GiB \
    set 1 esp on

partprobe "$DISK_PATH"
sleep 1

export BOOT="${DISK_PATH}p1"
export ZFS="${DISK_PATH}p2"

BOOT_DISK_UUID="$(blkid --match-tag UUID --output value $BOOT)"

info "Formatting boot & swap partition ..."
mkfs.vfat -n boot "$BOOT"

info "Creating '$ZFS_POOL' ZFS pool for '$ZFS' ..."
zpool create \
    -o ashift=12 \
    -o autotrim=on \
    -O acltype=posixacl \
    -O canmount=off \
    -O compression=zstd \
    -O dnodesize=auto \
    -O mountpoint=none \
    -O normalization=formD \
    -O relatime=on \
    -O xattr=sa \
    -f $ZFS_POOL $ZFS
ZFS_DISK_UUID="$(blkid --match-tag UUID --output value $ZFS)"

info "Creating '$ZFS_DS_ROOT' ZFS dataset ..."
zfs create -p -o mountpoint=legacy "$ZFS_DS_ROOT"

info "Creating '$ZFS_BLANK_SNAPSHOT' ZFS snapshot ..."
zfs snapshot "$ZFS_BLANK_SNAPSHOT"

info "Mounting '$ZFS_DS_ROOT' to /mnt ..."
mount -t zfs "$ZFS_DS_ROOT" /mnt

info "Mounting '$BOOT' to /mnt/boot ..."
mkdir -p /mnt/boot
mount -t vfat "$BOOT" /mnt/boot

info "Creating '$ZFS_DS_NIX' ZFS dataset ..."
zfs create -p -o mountpoint=legacy "$ZFS_DS_NIX"

info "Mounting '$ZFS_DS_NIX' to /mnt/nix ..."
mkdir -p /mnt/nix
mount -t zfs "$ZFS_DS_NIX" /mnt/nix

info "Creating '$ZFS_DS_HOME' ZFS dataset ..."
zfs create -p -o mountpoint=legacy "$ZFS_DS_HOME"

info "Mounting '$ZFS_DS_HOME' to /mnt/home ..."
mkdir -p /mnt/home
mount -t zfs "$ZFS_DS_HOME" /mnt/home

info "Creating '$ZFS_DS_PERSIST' ZFS dataset ..."
zfs create -p -o mountpoint=legacy "$ZFS_DS_PERSIST"

info "Mounting '$ZFS_DS_PERSIST' to /mnt/persist ..."
mkdir -p /mnt/persist
mount -t zfs "$ZFS_DS_PERSIST" /mnt/persist

info "Creating persistent directories ..."
mkdir -p /mnt/persist/etc/NetworkManager/system-connections
mkdir -p /mnt/persist/var/lib/bluetooth
# mkdir -p /mnt/persist/etc/ssh

LOCAL_PATH="/mnt/etc"
SAFE_PATH="/mnt/persist/etc"

info "Pulling remote NixOS configuration"
mkdir -p "${SAFE_PATH}"
git clone "${REMOTE}" "${SAFE_PATH}/nixos"

info "Generating NixOS configuration (/mnt/persist/etc/nixos/*.nix) ..."
FILE="${SAFE_PATH}/nixos/machines/${HOST}/hardware-configuration.nix"

if [ ! -f "$FILE" ]; then
    touch $FILE
fi

nixos-generate-config --root "/mnt" --show-hardware-config |
    tee $FILE >/dev/null

info "Copying configuraiton (/mnt/etc/nixos/*) ..."
mkdir -p "${LOCAL_PATH}"
cp -R "${SAFE_PATH}/nixos" "${LOCAL_PATH}"

info "Installing NixOS to /mnt ..."
nixos-install --root "/mnt" \
    --no-root-passwd \
    --flake "${SAFE_PATH}/nixos#${HOST}"

