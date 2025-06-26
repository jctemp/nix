{
  config,
  pkgs,
  lib,
  ctx,
  ...
}: let
  cfg = config.module.applications.web;
in {
  config = lib.mkIf cfg.enable {
    environment.systemPackages =
      [
        pkgs.curl
        pkgs.wget
        pkgs.httpie
      ]
      ++ cfg.packages
      ++ lib.optionals ctx.gui cfg.packagesWithGUI;
  };
}