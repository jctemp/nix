{lib, ...}: {
  imports = [./hardware-configuration.nix];
  hosts = {
    nvidia = {
      enable = true;
      open = true;
    };
    virtualisation = {
      docker.enable = true;
      libvirt.enable = true;
    };
  };
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback -r rpool/local/root@blank
  '';
  environment.etc = {
    "NetworkManager/system-connections" = {
      source = "/persist/etc/NetworkManager/system-connections/";
    };
    systemd.tmpfiles.rules = [
      "L /var/lib/bluetooth - - - - /persist/var/lib/bluetooth"
    ];
  };
}
