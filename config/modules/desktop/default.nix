{
  config,
  pkgs,
  lib,
  ...
}: {
  options.modules.desktop.enable = lib.mkOption {
    default = true;
    type = lib.types.bool;
    description = ''
      Enable GNOME desktop environment.
    '';
  };

  config = lib.mkIf config.modules.desktop.enable {
    programs.dconf.enable = true;
    services.xserver = {
      enable = true;
      displayManager.gdm = {
        enable = true;
        wayland = true;
      };
      desktopManager.gnome.enable = true;
    };

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    environment.systemPackages = [
      pkgs.gnomeExtensions.forge
      pkgs.adwaita-icon-theme
    ];
  };
}
