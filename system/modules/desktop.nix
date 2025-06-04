{
  config,
  pkgs,
  lib,
  ...
}: {
  options.modules.desktop = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable minimal X11 desktop infrastructure";
    };

    gnome.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable desktop manager (Gnome)";
    };
  };

  config = lib.mkIf config.modules.desktop.enable (lib.mkMerge [
    {
      services.xserver = {
        enable = true;
        xkb = {
          layout = "us";
          variant = "";
        };
      };

      programs.dconf.enable = true;
      services.accounts-daemon.enable = true;
      services.gvfs.enable = true;
      services.udisks2.enable = true;

      xdg.portal = {
        enable = true;
        extraPortals = [pkgs.xdg-desktop-portal-gtk];
      };

      fonts.fontconfig.enable = true;

      environment.systemPackages = with pkgs; [
        xorg.xinit
        xorg.xauth
        xterm
      ];
    }

    (lib.mkIf config.modules.desktop.gnome.enable {
      services.xserver = {
        displayManager.gdm = {
          enable = true;
          wayland = true;
        };
        desktopManager.gnome.enable = true;
      };
      services.power-profiles-daemon.enable = true;
      xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gnome];
    })
  ]);
}
