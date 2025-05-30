{
  config,
  pkgs,
  lib,
  ...
}: {
  # Define desktop module options
  options.modules.desktop = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable desktop environment";
    };

    environment = lib.mkOption {
      type = lib.types.enum ["gnome"];
      default = "gnome";
      description = "Desktop environment to use";
    };

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Additional packages to install for desktop use";
    };
  };

  # Implement desktop configurations
  config = lib.mkIf config.modules.desktop.enable (lib.mkMerge [
    # Common desktop settings
    {
      services.xserver.enable = true;
      programs.dconf.enable = true;
      services.accounts-daemon.enable = true;
      services.gvfs.enable = true;
      services.udisks2.enable = true;
      networking.networkmanager.enable = true;
      services.power-profiles-daemon.enable = true;
      xdg.portal.enable = true;
    }

    # Environment-specific configurations
    (lib.mkIf (config.modules.desktop.environment == "gnome") {
      services.xserver = {
        displayManager.gdm = {
          enable = true;
          wayland = true;
        };
        desktopManager.gnome.enable = true;
      };

      environment.systemPackages = with pkgs; [
        glib-networking
        trashy
        whitesur-gtk-theme
        whitesur-icon-theme
        gnome-tweaks
        gnomeExtensions.user-themes
        gnomeExtensions.forge
        gnomeExtensions.appindicator
        gnomeExtensions.dash-to-dock
      ];
    })
  ]);
}
