{
  config,
  pkgs,
  lib,
  ctx,
  ...
}: let
  cfg = config.module.core.security;
in {
  options.module.core.security = {
    applications = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "security applications to install for user";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = cfg.applications;
  };
}
