{
  config,
  lib,
  ...
}: let
  cfg = config.module.core.locale;
in {
  options.module.core.locale = {
    applications = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "locale applications to install for user";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = cfg.applications;
  };
}
