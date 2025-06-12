{
  pkgs,
  config,
  lib,
  utils,
  ctx,
  ...
}: let
  cfg = config.modules.system.gnome;

  sharedOptions = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = ctx.gui;
      description = "Enable GNOME desktop module";
    };
  };

  systemOptions = {
    wayland.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Wayland support";
    };

    excludePackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "GNOME packages to exclude";
    };
  };

  userOptions = {
    extensions = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "GNOME extensions to install";
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
in {
  options.modules.core.gnome =
    sharedOptions
    // (utils.mkIfSystem systemOptions)
    // (utils.mkIfUser userOptions);

  config = lib.mkMerge [
    (utils.mkIfSystemAnd (cfg.enable && ctx.gui) {
      services.xserver = {
        enable = true;
        xkb = {
          layout = "us";
          variant = "";
        };

        displayManager.gdm = {
          enable = true;
          wayland = cfg.enableWayland;
        };
        desktopManager.gnome.enable = true;
      };

      programs.dconf.enable = true;
      services.accounts-daemon.enable = true;
      services.gvfs.enable = true;
      services.udisks2.enable = true;
      services.power-profiles-daemon.enable = true;

      xdg.portal = {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
          xdg-desktop-portal-gnome
        ];
      };

      fonts.fontconfig.enable = true;

      environment.systemPackages = with pkgs; [
        xorg.xinit
        xorg.xauth
        xterm
      ];

      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };
    })
    (utils.mkIfHomeAnd (cfg.enable && ctx.gui) {
      home.packages =
        (with pkgs; [
          gnome-tweaks
          gnome-extension-manager
        ])
        ++ cfg.extensions;

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
    })
  ];
}
