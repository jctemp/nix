{
  config,
  pkgs,
  lib,
  ctx,
  ...
}: let
  cfg = config.module.core.boot;
in {
  options.module.core.boot = {
    loader = lib.mkOption {
      type = lib.types.enum ["systemd" "grub"];
      default = "systemd";
      description = "Boot loader type";
    };

    force = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Option for GRUB to forcefully install into environment";
    };

    kernelPackage = lib.mkOption {
      type = lib.types.enum ["default" "zen" "hardened" "extern"];
      default = "default";
      description = "Kernel package to use";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = 
      cfg.packages
      ++ lib.optionals ctx.gui cfg.packagesWithGUI;

    boot = {
      kernelPackages = lib.mkDefault (
        if cfg.kernelPackage == "default"
        then pkgs.linuxPackages
        else if cfg.kernelPackage == "zen"
        then pkgs.linuxPackages_zen
        else if cfg.kernelPackage == "hardened"
        then pkgs.linuxPackages_hardened
        else if cfg.kernelPackage == "extern"
        then config.boot.kernelPackages
        else throw "${cfg.kernelPackage} is invalid."
      );

      loader = lib.mkMerge [
        (lib.mkIf (cfg.loader == "systemd") {
          systemd-boot = {
            enable = true;
            configurationLimit = 5;
          };
          efi.canTouchEfiVariables = true;
        })
        (lib.mkIf (cfg.loader == "grub") {
          grub = {
            enable = true;
            efiSupport = true;
            configurationLimit = 5;
            zfsSupport = true;
            forceInstall = cfg.force;
          };
        })
      ];

      supportedFilesystems = ["btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" "zfs"];
      binfmt.emulatedSystems = ["x86_64-windows" "aarch64-linux"];
    };
  };
}