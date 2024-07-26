{zfsSupport ? false, ...}: {
  services.zfs = {
    autoScrub.enable = zfsSupport;
    autoSnapshot.enable = zfsSupport;
  };

  environment.etc =
    if zfsSupport
    then {
      "NetworkManager/system-connections" = {
        source = "/persist/etc/NetworkManager/system-connections/";
      };
    }
    else {};
}
