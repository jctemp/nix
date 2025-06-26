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
      [
        pkgs.gnome-tweaks
        pkgs.gnome-extension-manager
        pkgs.gnomeExtensions.forge
        pkgs.gnomeExtensions.blur-my-shell
        pkgs.gnomeExtensions.dash-to-dock
      ]
      ++ cfg.packages
      ++ cfg.packagesWithGUI;

    gtk = {
      enable = true;
      theme = {
        inherit (cfg.theme) name;
        inherit (cfg.theme) package;
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
        enabled-extensions = [
          "user-theme@gnome-shell-extensions.gcampax.github.com"
          "forge@jmmaranan.com"
          "dash-to-dock@micxgx.gmail.com"
          "blur-my-shell@aunetx"
        ];
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