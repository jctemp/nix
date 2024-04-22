{
  config,
  lib,
  ...
}: let
  cfg = config.hosts.boot;

  _ =
    lib.asserts.assertMsg (cfg.systemd-boot.enable || cfg.grub.enable) "Either systemd-boot or GRUB must be enabled"
    && lib.asserts.assertMsg (!(cfg.systemd-boot.enable && cfg.grub.enable)) "systemd-boot and GRUB are mutually exclusive";
in {
  imports = [];

  options.hosts.boot = {
    systemd-boot = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable systemd-boot.";
      };
    };
    grub = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable GRUB.";
      };
      device = lib.mkOption {
        type = lib.types.string;
        default = "/dev/sda";
        description = "The device to install GRUB to.";
      };
    };
    canTouchEfiVariables = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether the bootloader can touch EFI variables.";
    };
  };

  config = {
    boot = {
      supportedFilesystems = ["btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs"];
      loader = {
        efi.canTouchEfiVariables = cfg.canTouchEfiVariables;
        systemd-boot = {
          inherit (cfg.systemd-boot) enable;
          configurationLimit = 5;
        };
        grub = {
          inherit (cfg.grub) enable device;
          forceInstall = true;
          zfsSupport = true;
          efiSupport = true;
          configurationLimit = 5;
        };
      };
    };
  };
}
