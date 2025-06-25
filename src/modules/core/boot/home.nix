{
  config,
  lib,
  ...
}: let
  cfg = config.module.core.boot;
in {
  options.module.core.boot = {
    applications = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "boot applications to install for user";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = cfg.applications;
  };
}
