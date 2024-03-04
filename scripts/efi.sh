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

for disk in "${DISKS}"; do
    for part in $(ls "${disk}"*1); do
        if [ -e "${part}"]; then
            mkfs.vfat -n EFI "${part}"
        fi
    done
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
