{
  hostId,
  hostName,
  username,
  ...
}: {
  networking = {
    inherit hostId hostName;
    wireless.enable = false;
    networkmanager.enable = true;
  };

  users.users.${username}.extraGroups = ["networkmanager"];
}
