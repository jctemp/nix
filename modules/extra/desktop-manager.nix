{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.hosts.desktop;
in {
  imports = [];

  options.hosts.desktop = {
    enable = lib.mkEnableOption "Enable the GNOME desktop manager";
  };

  config = lib.mkIf cfg.enable {
    environment = {
      systemPackages = with pkgs; [
        gnome.adwaita-icon-theme
        gnomeExtensions.forge
        gnomeExtensions.vitals
      ];
    };

    programs.dconf.enable = true;

    services = {
      xserver = {
        enable = true;
        displayManager.gdm = {
          enable = true;
          wayland = true;
        };
        desktopManager.gnome.enable = true;
      };
    };
  };
}
