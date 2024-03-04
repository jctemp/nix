#!/bin/sh

MNT_NOT_SET=1
DISKS_NOT_SET=2
INVALID_BLOCK_DEVICE=3
DATASET_CREATION_FAILED=6

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
