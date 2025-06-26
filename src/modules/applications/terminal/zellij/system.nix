{
  config,
  pkgs,
  lib,
  ctx,
  ...
}: let
  cfg = config.module.applications.terminal.zellij;
in {
  config = lib.mkIf cfg.enable {
    environment.systemPackages =
      [pkgs.zellij]
      ++ cfg.packages
      ++ lib.optionals ctx.gui cfg.packagesWithGUI;
  };
}