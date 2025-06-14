{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.module.applications.ghostty;
in {
  options.module.core.ghostty = {
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Extra ghostty packages to install system-wide";
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [pkgs.ghostty] ++ cfg.extraPackages;
  };
}
