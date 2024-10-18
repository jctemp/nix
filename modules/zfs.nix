{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.module.zfs;
in {
  options.module.zfs = {
    enable = lib.mkOption {
      default = true;
      defaultText = "true";
      description = "Whether to enable the module.";
      type = lib.types.bool;
    };
    root = {
      enable = lib.mkOption {
        default = true;
        defaultText = "true";
        description = "Whether to enable the ZFS on root.";
        type = lib.types.bool;
      };
      rollback = lib.mkOption {
        default = ["rpool/local/root@blank"];
        defaultText = "[\"rpool/local/root@blank\"]";
        description = "zpool partition to rollback on start";
        type = lib.types.nullOr (lib.types.listOf lib.types.str);
      };
    };
  };

  config = {
    boot = {
      kernelPackages = lib.mkForce pkgs.linuxPackages;
      initrd.postDeviceCommands =
        lib.mkAfter (builtins.concatStringsSep "; "
          (lib.map (sn: "zfs rollback -r ${sn}") cfg.root.rollback));
      supportedFilesystems = ["zfs"];
    };

    services.zfs = {
      autoScrub.enable = true;
      autoSnapshot.enable = true;
      trim.enable = true;
      trim.interval = "weekly";
    };

    environment.etc = {
      "NetworkManager/system-connections" = {
        source = "/persist/etc/NetworkManager/system-connections/";
      };
    };

    systemd.tmpfiles.rules =
      if config.module.multimedia.bluetoothSupport
      then [
        # https://www.freedesktop.org/software/systemd/man/latest/tmpfiles.d.html
        "L /var/lib/bluetooth - - - - /persist/var/lib/bluetooth"
      ]
      else [];
  };
}
