{config, ...}: {
  networking = {
    hostName = config.hostSpec.hostName;
    hostId = builtins.substring 0 8 (builtins.hashString "md5" config.hostSpec.hostName);
    networkmanager.enable = true;
    firewall.enable = true;
    wireless.enable = false;
  };
}
