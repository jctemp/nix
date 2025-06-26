{
  config,
  pkgs,
  lib,
  ctx,
  ...
}: let
  cfg = config.module.core.printing;
in {
  config = lib.mkIf cfg.enable {
    home.packages =
      lib.optionals ctx.gui [
        pkgs.system-config-printer
        pkgs.evince
      ]
      ++ cfg.packages
      ++ lib.optionals ctx.gui cfg.packagesWithGUI;

    dconf.settings = lib.mkIf (ctx.gui && config.module.core.gnome.enable) {
      "org/gnome/desktop/interface" = {
        gtk-print-preview-command = "${pkgs.evince}/bin/evince --preview %s";
      };
    };
  };
}