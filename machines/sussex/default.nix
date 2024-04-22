{
  pkgs,
  lib,
  ...
}: {
  imports = [./hardware-configuration.nix];

  hosts = {
    desktop.enable = true;
    nvidia.enable = true;
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
    kernelPackages = pkgs.zfs.latestCompatibleLinuxPackages;
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
