{
  config,
  pkgs,
  lib,
  ctx,
  ...
}: let
  cfg = config.module.applications.productivity;
in {
  config = lib.mkIf cfg.enable {
    environment.systemPackages =
      cfg.packages
      ++ lib.optionals ctx.gui cfg.packagesWithGUI;

    fonts.packages = with pkgs; [
      liberation_ttf
      corefonts
      dejavu_fonts
    ];
  };
}