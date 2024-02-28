{
  hostId,
  hostName,
  userName,
  ...
}: {
  networking = {
    inherit hostId hostName;
    wireless.enable = false;
    networkmanager.enable = true;
  };

  users.users.${userName}.extraGroups = ["networkmanager"];
}
