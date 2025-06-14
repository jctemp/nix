{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.module.applications.productivity;
in {
  options.module.applications.productivity = {
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Extra productivity packages to install system-wide";
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = cfg.extraPackages;
    fonts.packages = with pkgs; [
      liberation_ttf
      corefonts
      dejavu_fonts
    ];
  };
}
