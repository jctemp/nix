{
  modulesPath,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
  ];

  hosts = {
    desktop.enable = false;
    virtualisation.docker.enable = true;
    boot = {
      systemd-boot.enable = true;
      canTouchEfiVariables = false;
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

  services = {
    zfs = {
      autoScrub.enable = true;
      autoSnapshot.enable = true;
    };
    cloud-init.network.enable = true;
  };

  environment.etc = {
    "NetworkManager/system-connections" = {
      source = "/persist/etc/NetworkManager/system-connections/";
    };
  };
}
