#!/bin/sh

# Error Codes
MNT_NOT_SET=1
DISKS_NOT_SET=2
INVALID_BLOCK_DEVICE=3
INVALID_RPOOL_PARTITION=5
DATASET_CREATION_FAILED=6

# ------------------ Input and Device Validation ------------------------------

if [ -z "${MNT}" ]; then
    echo "Error: MNT is not set."
    exit $MNT_NOT_SET
fi

if [ -z "${DISKS}" ]; then
    echo "Error: DISKS_IDS is not set."
    exit $DISKS_NOT_SET
fi

for disk in "${DISKS}"; do
    if [ ! -b $disk ]; then
        echo "$disk is not a block storage".
        exit $INVALID_BLOCK_DEVICE
    fi
done

if [ -z "${RESERVE}" ]; then
    echo "Warning: RESERVE is not set. Defaults to RESERVE=8."
    export RESERVE=8
fi

# ------------------ Disk Partitioning ----------------------------------------

partition_disk() {
    disk="${1}"
    blkdiscard -f "${id}" || true

    parted --script --align=optimal "${disk}" -- \
        mklabel gpt \
        mkpart EFI 1MiB 4GiB \
        mkpart rpool 4GiB -"${RESERVE}"GiB \
        set 1 esp on

    partprobe "${disk}"
    udevadm settle
}

for disk in ${DISKS}; do
    partition_disk "${disk}"
done

# ------------------ ZFS Configuration ----------------------------------------

rpool_args="rpool"

# 1. check the amount of disks (set mirror)
root_count=$(echo "${DISKS}" | wc -w)
if [ "${root_count}" -gt 1 ]; then
    rpool_args="${rpool_args} mirror"
fi

# 2. concat all disks to rpool_args
for disk in "${DISKS}"; do
    for part in $(ls "${disk}"*2); do
        if [ -e "${part}"]; then
            rpool_args="${rpool_args} ${part}"
        fi
    done
done

# 3. create zpool with rpool_args
zpool create \
    -R "${MNT}" \
    -o ashift=12 \
    -o autotrim=on \
    -O acltype=posixacl \
    -O canmount=off \
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

for disk in "${DISKS}"; do
    mkfs.vfat -n EFI "${disk}-part1"
    partprobe "${disk}"
done

udevadm settle

mkdir -p "${MNT}"/boot
for disk in "${DISKS}"; do
    for part in $(ls "${disk}"*1); do
        if [ -e "${part}"]; then
            mount "${part}" "${MNT}"/boot
            break
        fi
    done
done
