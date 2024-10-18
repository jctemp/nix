{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.module.boot;
in {
  options.module.boot = {
    loader = lib.mkOption {
      default = "systemd";
      defaultText = "systemd";
      description = "The type of loader to boot the system.";
      type = lib.types.enum ["systemd" "grub"];
    };
    device = lib.mkOption {
      default = "";
      defaultText = "null";
      description = "Which block device to use for boot. Only effects grub.";
      type = lib.types.str;
    };
    canTouchEfiVariables = lib.mkOption {
      default = true;
      defaultText = "true";
      description = "Wether the system can modify the EFI variables.";
      type = lib.types.bool;
    };
  };

  config = {
    boot = {
      loader = {
        grub = lib.mkIf (cfg.loader == "grub") {
          enable = true;
          forceInstall = true;
          efiSupport = true;
          configurationLimit = 5;
          zfsSupport = config.module.zfs.enable;
          inherit (cfg) device;
        };

        systemd-boot = lib.mkIf (cfg.loader == "systemd") {
          enable = true;
          configurationLimit = 5;
        };
      };
      loader.efi.canTouchEfiVariables = true;
      supportedFilesystems = [
        "btrfs"
        "reiserfs"
        "vfat"
        "f2fs"
        "xfs"
        "ntfs"
        "cifs"
      ];
    };
  };
}
