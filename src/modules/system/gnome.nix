{
  pkgs,
  config,
  lib,
  utils,
  ...
}: let
  cfg = config.modules.system.gnome;
in {
  options.modules.system.gnome = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable GNOME module";
    };
    wayland.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Wayland support";
    };
  };

  config = lib.mkMerge [
    (utils.mkIfSystemAnd (cfg.enable) {
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
    (utils.mkIfHomeAnd (cfg.enable) {
      })
  ];
}
