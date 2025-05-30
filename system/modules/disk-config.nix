{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: let
  hostDevice = config.modules.hostSpec.disk or "/dev/sda";
  loaderType = config.modules.hostSpec.loader or "systemd";
  persistedDataPath = config.modules.hostSpec.safePath or "/persist";

  kernelPackages =
    if config.modules.hostSpec.kernelPackage == "default"
    then pkgs.linuxPackages
    else if config.modules.hostSpec.kernelPackage == "zen"
    then pkgs.linuxPackages_zen
    else if config.modules.hostSpec.kernelPackage == "hardened"
    then pkgs.linuxPackages_hardened
    else if config.modules.hostSpec.kernelPackage == "custom"
    then config.modules.hostSpec.kernelPackages
    else builtins.throw "kernelPackage ${config.modules.hostSpec.kernelPackage} is unknown. check hostSpec configuration";

  loader =
    if config.modules.hostSpec.loader == "systemd"
    then {
      systemd-boot = lib.mkIf (loaderType == "systemd") {
        enable = true;
        configurationLimit = 5;
      };
      efi.canTouchEfiVariables = loaderType == "systemd";
    }
    else if config.modules.hostSpec.loader == "grub"
    then {
      grub = lib.mkIf (loaderType == "grub") {
        enable = true;
        forceInstall = true; # Required for remote VM
        efiSupport = true;
        configurationLimit = 5;
        zfsSupport = true;
        device = hostDevice;
      };
    }
    else builtins.throw "loader type ${config.modules.hostSpec.loader} is unknown. check hostSpec configuration";

  zfsPoolName = "rpool";
  zfsRootDataset = "local/root";
  zfsRootFsPath = "${zfsPoolName}/${zfsRootDataset}";
  zfsSnapshotBlank = "${zfsRootFsPath}@blank";

  zfsRollbackCommand = "zfs rollback -r ${zfsSnapshotBlank}";
  createBlankSnapshotScript = ''
    set -o errexit  # Exit on error
    set -o nounset  # Exit on unset variables
    set -o pipefail # Exit on pipe failures

    if ! zfs list -t snapshot -H -o name | grep -q -E '^${lib.escapeShellArg zfsSnapshotBlank}$'; then
      echo "Creating blank snapshot: ${zfsSnapshotBlank}"
      zfs snapshot "${zfsSnapshotBlank}"
    else
      echo "Blank snapshot already exists: ${zfsSnapshotBlank}"
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
        kernelPackages = lib.mkDefault kernelPackages;
        inherit loader;

        initrd.postDeviceCommands = lib.mkAfter zfsRollbackCommand;
        supportedFilesystems = ["btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" "zfs"];
        binfmt.emulatedSystems = ["x86_64-windows" "aarch64-linux"];
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
                boot = {
                  label = "BOOT";
                  size = "1M";
                  type = "EF02"; # Symbolic type for bios_boot
                };
                esp = {
                  label = "EFI";
                  size = "2G";
                  type = "EF00"; # Symbolic type for ESP
                  content = {
                    type = "filesystem";
                    format = "vfat";
                    mountpoint = "/boot";
                    mountOptions = ["umask=0077"];
                  };
                };
                encryptedSwap = {
                  size = "128M";
                  content = {
                    type = "swap";
                    randomEncryption = true;
                    priority = 100;
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
