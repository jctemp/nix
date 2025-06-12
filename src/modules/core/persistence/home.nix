{
  config,
  pkgs,
  lib,
  ctx,
  ...
}: let
  cfg = config.module.core.persistence;
in {
  options.module.core.persistence = {
    applications = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "persistence applications to install for user";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = cfg.applications;
  };
}
