{
  config,
  pkgs,
  lib,
  ctx,
  ...
}: let
  cfg = config.module.core.gnome;
in {
  options.module.core.gnome = {
    applications = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "GNOME applications to install for user";
    };

    theme = {
      name = lib.mkOption {
        type = lib.types.str;
        default = "Adwaita-dark";
        description = "GTK theme name";
      };

      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.gnome-themes-extra;
        description = "GTK theme package";
      };
    };
  };

  config = lib.mkIf (cfg.enable && ctx.gui) {
    home.packages =
      (with pkgs; [
        gnome-tweaks
        gnome-extension-manager
      ])
      ++ cfg.applications;

    gtk = {
      enable = true;
      theme = {
        name = cfg.theme.name;
        package = cfg.theme.package;
      };
      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
    };

    dconf.settings = {
      "org/gnome/desktop/interface" = {
        gtk-theme = cfg.theme.name;
        color-scheme = "prefer-dark";
        enable-hot-corners = false;
      };

      "org/gnome/desktop/wm/preferences" = {
        button-layout = "appmenu:maximize,minimize,close";
      };

      "org/gnome/shell" = {
        disable-user-extensions = false;
      };
    };

    xdg = {
      enable = true;
      userDirs = {
        enable = true;
        createDirectories = true;
      };
    };
  };
}
