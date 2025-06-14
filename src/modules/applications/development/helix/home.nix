{
  config,
  lib,
  ...
}: let
  cfg = config.module.applications.helix;
in {
  options.module.core.helix = {
    applications = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Helix applications to install for user";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = cfg.applications;
  };
}
