{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "to-be-filled-during-installation";
        content = {
          type = "gpt";
          partitions = {
            efi = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot/esp";
                mountOptions = ["umask=0077"];
              };
            };
            bpool = {
              size = "4G";
              content = {
                type = "zfs";
                pool = "bpool";
              };
            };
            rpool = {
              end = "-4G";
              content = {
                type = "zfs";
                pool = "rpool";
              };
            };
            bios = {
              size = "1M";
              type = "EF02";
            };
          };
        };
      };
    };
    zpool = {
      bpool = {
        type = "zpool";
        mountpoint = "/boot";
        options = {
          ashift = "12";
          autotrim = "on";
          compatibility = "grub2";
        };
        rootFsOptions = {
          acltype = "posixacl";
          canmount = "off";
          compression = "zstd";
          dnodesize = "auto";
          normalization = "formD";
          relatime = "on";
          xattr = "sa";
          "com.sun:auto-snapshot" = "false";
        };
        datasets = {
          nixos = {
            type = "zfs_fs";
            options.mountpoint = "none";
          };
          "nixos/root" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/boot";
          };
        };
      };
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
          compression = "zstd";
          dnodesize = "auto";
          normalization = "formD";
          relatime = "on";
          xattr = "sa";
          "com.sun:auto-snapshot" = "false";
        };
        datasets = {
          nixos = {
            type = "zfs_fs";
            options.mountpoint = "none";
          };
          "nixos/root" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/";
            postCreateHook = "zfs snapshot rpool/nixos/root@empty";
          };
          "nixos/home" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/home";
          };
          "nixos/persist" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/persist";
          };
          "nixos/nix" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/nix";
          };
        };
      };
    };
  };
}
