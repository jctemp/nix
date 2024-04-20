{
  pkgs,
  lib,
  ...
}: {
  imports = [./hardware-configuration.nix];

  hosts = {
    nvidia = {
      enable = true;
      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
    virtualisation = {
      docker.enable = true;
      libvirt.enable = true;
    };
    boot = {
      systemd-boot.enable = true;
      canTouchEfiVariables = true;
    };
  };

  boot = {
    kernelPackages = lib.mkForce pkgs.zfs.latestCompatibleLinuxPackages;
    supportedFilesystems = lib.mkForce ["zfs"];
    initrd.postDeviceCommands = lib.mkAfter ''
      zfs rollback -r rpool/local/root@blank
    '';
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
  };

  systemd.tmpfiles.rules = [
    # https://www.freedesktop.org/software/systemd/man/latest/tmpfiles.d.html
    # create symlink to
    "L /var/lib/bluetooth - - - - /persist/var/lib/bluetooth"
  ];
}
