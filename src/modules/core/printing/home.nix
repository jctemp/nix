{
  config,
  pkgs,
  lib,
  ctx,
  ...
}: let
  cfg = config.module.core.printing;
in {
  options.module.core.printing = {
    applications = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "printing applications to install for user";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      lib.mkIf (ctx.gui) (with pkgs; [
        system-config-printer
        evince
      ])
      ++ cfg.applications;

    dconf.settings = lib.mkIf (ctx.gui && config.modules.core.gnome.enable) {
      "org/gnome/desktop/interface" = {
        gtk-print-preview-command = "${pkgs.evince}/bin/evince --preview %s";
      };
    };
  };
}
