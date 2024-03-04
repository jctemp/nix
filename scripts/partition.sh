#!/bin/sh

MNT_NOT_SET=1
DISKS_NOT_SET=2
INVALID_BLOCK_DEVICE=3

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

partition_disk() {
    disk="${1}"
    blkdiscard -f "${disk}" || true

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