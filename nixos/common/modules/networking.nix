{
  hostId,
  hostName,
  user,
  ...
}: {
  networking = {
    inherit hostId hostName;
    wireless.enable = false;
    networkmanager.enable = true;
  };

  users.users.${user}.extraGroups = ["networkmanager"];
}
