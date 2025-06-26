{
  config,
  lib,
  ctx,
  ...
}: let
  cfg = config.module.core.persistence;
in {
  options.module.core.persistence = {
    disk = lib.mkOption {
      type = lib.types.str;
      default = "/dev/sda";
      description = "Disk device for disko configuration";
    };

    persistPath = lib.mkOption {
      type = lib.types.str;
      default = "/persist";
      description = "Path for persistent data";
    };
  };

  config = let
    zfsPoolName = "rpool";
    zfsRootDataset = "local/root";
    zfsRootFsPath = "${zfsPoolName}/${zfsRootDataset}";
    zfsSnapshotBlank = "${zfsRootFsPath}@blank";
    zfsRollbackCommand = "zfs rollback -r ${zfsSnapshotBlank}";

    createBlankSnapshotScript = ''
      set -o errexit
      set -o nounset
      set -o pipefail

      if ! zfs list -t snapshot -H -o name | grep -q -E '^${lib.escapeShellArg zfsSnapshotBlank}$'; then
        echo "Creating blank snapshot: ${zfsSnapshotBlank}"
        zfs snapshot "${zfsSnapshotBlank}"
      else
        echo "Blank snapshot already exists: ${zfsSnapshotBlank}"
      fi
    '';
  in
    lib.mkIf cfg.enable {
      environment.systemPackages = 
        cfg.packages
        ++ lib.optionals ctx.gui cfg.packagesWithGUI;

      boot.initrd.postDeviceCommands = lib.mkAfter zfsRollbackCommand;

      services.zfs = {
        autoScrub.enable = true;
        autoSnapshot.enable = false;
        trim.enable = true;
        trim.interval = "weekly";
      };

      environment.persistence."${cfg.persistPath}" = {
        enable = true;
        hideMounts = true;
        directories = [
          "/var/lib/systemd/coredump"
          "/var/lib/nixos"
          "/etc/NetworkManager/system-connections"
        ];
      };

      fileSystems."${cfg.persistPath}".neededForBoot = true;

      disko.devices = {
        disk.main = {
          imageName = "nixos-disko-root-zfs";
          device = cfg.disk;
          type = "disk";
          content = {
            type = "gpt";
            partitions = {
              boot = {
                label = "BOOT";
                size = "1M";
                type = "EF02";
              };
              esp = {
                label = "EFI";
                size = "2G";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = ["umask=0077"];
                };
              };
              encryptedSwap = {
                size = "16G";
                content = {
                  type = "swap";
                  randomEncryption = true;
                  priority = 100;
                };
              };
              root = {
                size = "100%";
                content = {
                  type = "zfs";
                  pool = zfsPoolName;
                };
              };
            };
          };
        };

        zpool."${zfsPoolName}" = {
          type = "zpool";
          mountpoint = "/";
          options = {
            ashift = "12";
            autotrim = "on";
          };
          rootFsOptions = {
            acltype = "posixacl";
            canmount = "off";
            dnodesize = "auto";
            normalization = "formD";
            relatime = "on";
            xattr = "sa";
            compression = "zstd";
          };
          datasets = {
            "local" = {
              type = "zfs_fs";
              options.mountpoint = "none";
            };
            "${zfsRootDataset}" = {
              type = "zfs_fs";
              options.mountpoint = "legacy";
              mountpoint = "/";
              postCreateHook = createBlankSnapshotScript;
            };
            "local/nix" = {
              type = "zfs_fs";
              options.mountpoint = "legacy";
              mountpoint = "/nix";
            };
            "safe" = {
              type = "zfs_fs";
              options.mountpoint = "none";
            };
            "safe/home" = {
              type = "zfs_fs";
              options.mountpoint = "legacy";
              mountpoint = "/home";
            };
            "safe/persist" = {
              type = "zfs_fs";
              options.mountpoint = "legacy";
              mountpoint = cfg.persistPath;
            };
          };
        };
      };
    };
}
