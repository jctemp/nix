{ config, lib, pkgs, ... }:

{
  boot.initrd = {
    availableKernelModules = [
      "virtio_pci"  # disk
      "virtio_scsi" # disk
    ];
    kernelModules = [
      "dm-snapshot"
    ];
  };
}