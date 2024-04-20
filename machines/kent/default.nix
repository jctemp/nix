{pkgs, lib, ...}: {
  imports = [./hardware-configuration.nix];

  hosts = {
    virtualisation.docker.enable = true;
    boot = {
      grub = {
        enable = true;
        device = "/dev/sda";
      };
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

  services.zfs = {
    autoScrub.enable = true;
    autoSnapshot.enable = true;
  };

  environment.etc = {
    "NetworkManager/system-connections" = {
      source = "/persist/etc/NetworkManager/system-connections/";
    };
  };
}
