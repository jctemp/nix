{
  pkgs,
  lib,
  ...
}: {
  imports = [./hardware-configuration.nix];

  hosts = {
    nvidia = {
      enable = true;
      open = true;
    };
    virtualisation = {
      docker.enable = true;
      libvirt.enable = true;
    };
  };

  boot = {
    kernelPackages = lib.mkForce pkgs.zfs.latestCompatibleLinuxPackages;
    supportedFilesystems = lib.mkForce ["btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" "zfs"];
    zfs.forceImportRoot = false;

    initrd.postDeviceCommands = lib.mkAfter ''
      zfs rollback -r rpool/local/root@blank
    '';

    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      grub = {
        enable = true;
        zfsSupport = true;
        efiSupport = true;
        devices = ["/dev/nvme0n1"];
        useOSProber = true;
        configurationLimit = 10;
      };
    };
  };

  time.hardwareClockInLocalTime = true;

  services.zfs = {
    autoScrub.enable = true;
    autoSnapshot.enable = true;
  };

  environment.etc = {
    "NetworkManager/system-connections" = {
      source = "/persist/etc/NetworkManager/system-connections/";
    };
    "ssh" = {
      source = "/persist/etc/ssh";
    };
    "grub.d" = {
      source = "/persist/etc/grub.d";
    };
  };

  systemd.tmpfiles.rules = [
    "L /var/lib/bluetooth - - - - /persist/var/lib/bluetooth"
  ];
}
