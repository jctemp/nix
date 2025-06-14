{
  config,
  lib,
  ...
}: let
  cfg = config.module.applications.development.helix;
in {
  options.module.applications.development.helix = {
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Extra helix packages to install system-wide";
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = cfg.extraPackages;
  };
}
