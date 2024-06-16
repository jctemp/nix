{pkgs, ...}: {
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

  environment.systemPackages = [
    pkgs.gnome.adwaita-icon-theme
    pkgs.gnomeExtensions.forge
    pkgs.gnomeExtensions.vitals
  ];
}
