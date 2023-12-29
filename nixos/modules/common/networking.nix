{
  config,
  lib,
  ...
}: let
  cfg = config.host.networking;
in {
  imports = [];

  options.host.networking = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable networking via NetworkManager";
    };
    hostName = lib.mkOption {
      type = lib.types.str;
      default = "nixos";
      description = "Hostname of the machine";
    };
    users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Users allowed to use NetworkManager";
    };
  };

  config = lib.mkIf cfg.enable {
    networking = {
      hostName = cfg.hostName;
      wireless.enable = false;
      networkmanager.enable = true;
    };

    users.users =
      builtins.foldl'
      (result: set: result // set)
      {}
      (
        builtins.map
        (user: {${user} = {extraGroups = ["networkmanager"];};})
        cfg.users
      );
  };
}
