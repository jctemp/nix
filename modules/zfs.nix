{
  config,
  lib,
  pkgs,
  ...
}: {
  boot = {
    kernelPackages = lib.mkForce pkgs.linuxPackages;
    supportedFilesystems = ["zfs"];
    # initrd.postDeviceCommands =
    #   lib.mkAfter (builtins.concatStringsSep "; "
    #     (lib.map (sn: "zfs rollback -r ${sn}") "rpool/local/root@blank"));
  };

  services.zfs = {
    autoScrub.enable = true;
    autoSnapshot.enable = true;
    trim.enable = true;
    trim.interval = "weekly";
  };

  environment.etc = {
    "NetworkManager/system-connections" = {
      source = "/persist/etc/NetworkManager/system-connections/";
    };
  };

  systemd.tmpfiles.rules =
    if config.module.multimedia.bluetoothSupport
    then [
      # https://www.freedesktop.org/software/systemd/man/latest/tmpfiles.d.html
      "L /var/lib/bluetooth - - - - /persist/var/lib/bluetooth"
    ]
    else [];
}
