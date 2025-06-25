{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.module.core.users;
in {
  options.module.core.users = {
    applications = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "users applications to install for user";
    };
  };

  config = {
    home.packages = cfg.applications;
  };
}
