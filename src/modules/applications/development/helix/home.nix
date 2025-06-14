{
  config,
  lib,
  ...
}: let
  cfg = config.module.applications.development.helix;
in {
  options.module.applications.development.helix = {
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
