#!/bin/sh

# Error Codes
MNT_NOT_SET=1
DISKS_IDS_NOT_SET=2
INVALID_BLOCK_DEVICE=3
INVALID_DEVICE_PATH=4
PARTITION_FAILED=5
INVALID_RPOOL_PARTITION=6
DATASET_CREATION_FAILED=7

# ------------------ Input and Device Validation ------------------------------

if [ -z "${MNT}" ]; then
    echo "Error: MNT is not set."
    exit $MNT_NOT_SET
fi

if [ -z "${DISKS_IDS}" ]; then
    echo "Error: DISKS_IDS is not set."
    exit $DISKS_IDS_NOT_SET
fi

for id in "${DISKS_IDS}"; do
    if
        ! lsblk "${id}" &
        >/dev/null
    then
        echo "Error: '${id}' is not a block device"
        exit $INVALID_BLOCK_DEVICE
    fi

    if [ $(dirname "${id}") != "/dev/disk/by-id" ]; then
        echo "Error: '${id}' is not an id (/dev/disk/by-id)"
        exit $INVALID_DEVICE_PATH
    fi

done
unset id

if [ -z "${RESERVE}" ]; then
    echo "Warning: RESERVE is not set. Defaults to RESERVE=8."
    export RESERVE=8
fi

# ------------------ Disk Partitioning ----------------------------------------

partition_disk() {
    id="${1}"
    if ! blkdiscard -f "${id}" 2>/dev/null; then
        echo "Warning: Failed to erase data on disk ${id}. Continuing..."
    fi

    if ! parted --script --align=optimal "${id}" -- \
        mklabel gpt \
        mkpart EFI 1MiB 4GiB \
        mkpart rpool 4GiB -$((RESERVE))GiB \
        set 1 esp on 2>/dev/null; then

        echo "Error: Failed to partition disk ${id}"
        exit $PARTITION_FAILED
    fi

    partprobe "${id}"
    udevadm settle
    unset id
}

for id in ${DISKS_IDS}; do
    partition_disk "${id}"
done

# ------------------ ZFS Configuration ----------------------------------------

rpool_args="rpool"

# 1. check the amount of disks (set mirror)
root_count=$(echo "${DISKS_IDS}" | wc -w)
if [ "${root_count}" -gt 1 ]; then
    rpool_args="${rpool_args} mirror"
fi

# 2. concat all disks to rpool_args
for id in "${DISKS_IDS}"; do
    rpool_args="${rpool_args} ${id}-part2"
done

# 3. create zpool with rpool_args
zpool create \
    -R "${MNT}" \
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
    "${rpool_args}"

# helper function to check ZFS status code
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

# ------------------ Mounting -------------------------------------------------

mount -t zfs rpool/local/root "/${MNT}"

mkdir -p "${MNT}"/nix
mkdir -p "${MNT}"/home
mkdir -p "${MNT}"/persist

mount -t zfs rpool/local/nix "${MNT}"/nix
mount -t zfs rpool/safe/home "${MNT}"/home
mount -t zfs rpool/safe/persist "${MNT}"/persist

# ------------------ EFI Partition  -------------------------------------------

for id in "${DISKS_IDS}"; do
    mkfs.vfat -n EFI "${id}-part1"
    partprobe "${id}"
done

udevadm settle

mkdir -p "${MNT}"/boot
for id in "${DISKS_IDS}"; do
    mount "${id}-part1" "${MNT}"/boot
    break
done
