{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: let
  # Extract values from the hostSpec
  loaderType = config.modules.hostSpec.loader or "systemd";
  device = config.modules.hostSpec.device or "/dev/sda";
  safePath = config.modules.hostSpec.safePath or "/persist";
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
        # Use the regular Linux kernel
        kernelPackages = lib.mkForce pkgs.linuxPackages;

        # Boot loader configuration based on hostSpec
        loader = {
          grub = lib.mkIf (loaderType == "grub") {
            enable = true;
            forceInstall = true;
            efiSupport = true;
            configurationLimit = 5;
            zfsSupport = true;
            inherit device;
          };

          systemd-boot = lib.mkIf (loaderType == "systemd") {
            enable = true;
            configurationLimit = 5;
          };

          efi.canTouchEfiVariables = loaderType == "systemd";
        };

        # Support for various filesystems
        supportedFilesystems = [
          "btrfs"
          "reiserfs"
          "vfat"
          "f2fs"
          "xfs"
          "ntfs"
          "cifs"
          "zfs"
        ];

        # Support for binary formats
        binfmt.emulatedSystems = [
          "x86_64-windows"
          "aarch64-linux"
        ];

        # ZFS rollback commands for resetting root
        initrd.postDeviceCommands = lib.mkAfter (
          builtins.concatStringsSep "; " (
            lib.map (sn: "zfs rollback -r ${sn}") [
              "rpool/local/root@blank"
            ]
          )
        );
      };
    }

    # ZFS configuration
    {
      # ZFS service configuration
      services.zfs = {
        autoScrub.enable = true;
        autoSnapshot.enable = true;
        trim.enable = true;
        trim.interval = "weekly";
      };
    }

    # Persistence configuration
    {
      # Persistence configuration
      environment.persistence.${safePath} = {
        enable = true;
        hideMounts = true;
        directories =
          [
            "/var/lib/systemd/coredump"
            "/var/lib/nixos"
            "/etc/NetworkManager/system-connections"
          ]
          ++ (
            lib.optional config.modules.hardware.bluetooth.enable "/var/lib/bluetooth"
          );
      };

      # Ensure the persistence path is mounted
      fileSystems.${safePath}.neededForBoot = true;
    }

    # Facter configuration
    {
      # Set the facter report path
      facter.reportPath = "${inputs.self}/hosts/${config.networking.hostName}/facter.json";
    }

    # Disko disk configuration
    {
      disko.devices = {
        disk = {
          main = {
            inherit device;
            imageName = "nixos-disko-root-zfs";
            imageSize = "32G";
            type = "disk";
            content = {
              type = "gpt";
              partitions = {
                boot = {
                  label = "BOOT";
                  size = "1M";
                  type = "EF02"; # for GRUB MBR
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
                    pool = "rpool";
                  };
                };
              };
            };
          };
        };

        zpool = {
          rpool = {
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
              local = {
                type = "zfs_fs";
                options.mountpoint = "none";
              };
              "local/root" = {
                type = "zfs_fs";
                options.mountpoint = "legacy";
                mountpoint = "/";
                postCreateHook = ''
                  zfs list -t snapshot -H -o name | grep -E '^rpool/local/root@blank$' \
                  || zfs snapshot rpool/local/root@blank
                '';
              };
              "local/nix" = {
                type = "zfs_fs";
                options.mountpoint = "legacy";
                mountpoint = "/nix";
              };
              safe = {
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
                mountpoint = safePath;
              };
            };
          };
        };
      };
    }
  ];
}
