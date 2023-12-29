{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.host.docker;
in {
  imports = [];

  options.host.docker = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable docker daemon";
    };
    rootless = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable rootless docker daemon";
    };
    nvidia = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable nvidia support for docker";
    };
    users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Users allowed to use docker";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation = {
      docker = {
        enable = true;
        rootless = {
          enable = cfg.rootless;
          setSocketVariable = true;
        };
        enableNvidia = cfg.nvidia;
      };
    };

    environment.systemPackages = [
      pkgs.docker-compose
      pkgs.lazydocker
    ];

    users.users = builtins.foldl' (result: set: result // set) {} (
      builtins.map
      (user: {${user} = {extraGroups = ["docker"];};})
      cfg.users
    );
  };
}
