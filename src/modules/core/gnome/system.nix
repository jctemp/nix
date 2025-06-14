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
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Extra packages to install system-wide";
    };

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

  config = lib.mkIf (cfg.enable && ctx.gui) {
    environment.systemPackages = with pkgs;
      [
        xorg.xinit
        xorg.xauth
        xterm
      ]
      ++ cfg.extraPackages;

    services.xserver = {
      enable = true;
      xkb = {
        layout = "us";
        variant = "";
      };

      displayManager.gdm = {
        enable = true;
        wayland = cfg.wayland.enable;
      };
      desktopManager.gnome.enable = true;
    };

    programs.dconf.enable = true;
    services.accounts-daemon.enable = true;
    services.gvfs.enable = true;
    services.power-profiles-daemon.enable = true;
    services.udisks2.enable = true;

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-gnome
      ];
    };

    fonts.fontconfig.enable = true;
  };
}
