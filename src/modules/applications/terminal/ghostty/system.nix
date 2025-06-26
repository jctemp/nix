{
  config,
  pkgs,
  lib,
  ctx,
  ...
}: let
  cfg = config.module.applications.terminal.ghostty;
in {
  config = lib.mkIf cfg.enable {
    environment.systemPackages = 
      [pkgs.ghostty]
      ++ cfg.packages
      ++ lib.optionals ctx.gui cfg.packagesWithGUI;
  };
}