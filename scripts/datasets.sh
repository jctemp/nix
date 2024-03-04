#!/bin/sh

MNT_NOT_SET=1
DATASET_CREATION_FAILED=6

if [ -z "${MNT}" ]; then
    echo "Error: MNT is not set."
    exit $MNT_NOT_SET
fi

zfs_check_status() {
    if [ $? -ne 0 ]; then
        echo "Error: Failed to create ZFS dataset $1"
        exit $DATASET_CREATION_FAILED
    fi
}

zfs create -o mountpoint=none rpool/local # non-persistent storage
zfs_check_status "rpool/local"
zfs create -o mountpoint=legacy rpool/local/root # OS data
zfs_check_status "rpool/local/root"
zfs create -o mountpoint=legacy rpool/local/nix # nix store
zfs_check_status "rpool/local/nix"

zfs create -o mountpoint=none rpool/safe # persistent storage
zfs_check_status "rpool/safe"
zfs create -o mountpoint=legacy rpool/safe/home # user files
zfs_check_status "rpool/safe/home"
zfs create -o mountpoint=legacy rpool/safe/persist # arbitrary data
zfs_check_status "rpool/safe/persist"

zfs snapshot rpool/local/root@blank

mount -t zfs rpool/local/root "/${MNT}"

mkdir -p "${MNT}"/nix
mkdir -p "${MNT}"/home
mkdir -p "${MNT}"/persist

mount -t zfs rpool/local/nix "${MNT}"/nix
mount -t zfs rpool/safe/home "${MNT}"/home
mount -t zfs rpool/safe/persist "${MNT}"/persist