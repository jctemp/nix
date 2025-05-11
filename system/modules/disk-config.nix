{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: let
  hostDevice = config.modules.hostSpec.device or "/dev/sda";
  loaderType = config.modules.hostSpec.loader or "systemd";
  persistedDataPath = config.modules.hostSpec.safePath or "/persist";

  zfsPoolName = "rpool";
  zfsRootDataset = "local/root";
  zfsRootFsPath = "${zfsPoolName}/${zfsRootDataset}";
  blankSnapshotSuffix = "@blank";
  fullBlankSnapshotName = "${zfsRootFsPath}${blankSnapshotSuffix}";
  zfsRollbackCommand = "zfs rollback -r ${fullBlankSnapshotName}";

  createBlankSnapshotScript = pkgs.writeShellScript "create-blank-snapshot.sh" ''
    set -o errexit  # Exit on error
    set -o nounset  # Exit on unset variables
    set -o pipefail # Exit on pipe failures

    if ! zfs list -t snapshot -H -o name | grep -q -E '^${lib.escapeShellArg fullBlankSnapshotName}$'; then
      echo "Creating blank snapshot: ${fullBlankSnapshotName}"
      zfs snapshot "${fullBlankSnapshotName}"
    else
      echo "Blank snapshot already exists: ${fullBlankSnapshotName}"
    fi
  '';
in {
  imports = [
    inputs.disko.nixosModules.disko
    inputs.nixos-facter-modules.nixosModules.facter
    inputs.impermanence.nixosModules.impermanence
  ];

  # Configure the system
  config = lib.mkMerge [
    # Boot configuration
    {
      boot = {
        kernelPackages = lib.mkForce pkgs.linuxPackages;

        loader = {
          grub = lib.mkIf (loaderType == "grub") {
            enable = true;
            efiSupport = true;
            configurationLimit = 5;
            zfsSupport = true;
            device = hostDevice;
          };
          systemd-boot = lib.mkIf (loaderType == "systemd") {
            enable = true;
            configurationLimit = 5;
          };
          efi.canTouchEfiVariables = loaderType == "systemd";
        };

        supportedFilesystems = ["btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" "zfs"];
        binfmt.emulatedSystems = ["x86_64-windows" "aarch64-linux"];

        initrd.postDeviceCommands = lib.mkAfter zfsRollbackCommand;
      };
    }

    # ZFS configuration
    {
      services.zfs = {
        autoScrub.enable = true;
        autoSnapshot.enable = false;
        trim.enable = true;
        trim.interval = "weekly";
      };
    }

    # Persistence configuration
    {
      environment.persistence."${persistedDataPath}" = {
        enable = true;
        hideMounts = true;
        directories =
          [
            "/var/lib/systemd/coredump"
            "/var/lib/nixos"
            "/etc/NetworkManager/system-connections"
          ]
          ++ (lib.optional config.modules.hardware.bluetooth.enable "/var/lib/bluetooth");
      };
      fileSystems."${persistedDataPath}".neededForBoot = true;
    }

    # Facter configuration
    {
      # Set the facter report path
      facter.reportPath = "${inputs.self}/system/hosts/${config.networking.hostName}/facter.json";
    }

    # Disko disk configuration
    {
      disko.devices = {
        disk = {
          main = {
            device = hostDevice;
            imageName = "nixos-disko-root-zfs";
            imageSize = "32G";
            type = "disk";
            content = {
              type = "gpt";
              partitions = {
                boot = lib.mkIf (loaderType == "grub") {
                  label = "BOOT";
                  size = "1M";
                  type = "bios_boot"; # Symbolic type for EF02
                };
                esp = {
                  label = "EFI";
                  size = "2G";
                  type = "ESP"; # Symbolic type for EF00
                  content = {
                    type = "filesystem";
                    format = "vfat";
                    mountpoint = "/boot";
                    mountOptions = ["umask=0077"];
                  };
                };
                encryptedSwap = {
                  size = "128M";
                  priority = 100;
                  content = {
                    type = "swap";
                    randomEncryption = true;
                  };
                };
                swap = {
                  size = "4G";
                  content = {
                    type = "swap";
                    discardPolicy = "both";
                    resumeDevice = true;
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
        };

        zpool = {
          "${zfsPoolName}" = {
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
                mountpoint = persistedDataPath;
              };
            };
          };
        };
      };
    }
  ];
}
