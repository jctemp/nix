# Desktop environment
# - Window manager customization, themes, and icon packs.
# - System tray applications, panel applets
{pkgs, ...}: {
  environment = {
    gnome.excludePackages =
      (with pkgs; [
        gnome-photos
        gnome-tour
      ])
      ++ (with pkgs.gnome; [
        cheese # webcam tool
        gnome-music
        gnome-terminal
        gedit # text editor
        epiphany # web browser
        geary # email reader
        evince # document viewer
        gnome-characters
        totem # video player
        tali # poker game
        iagno # go game
        hitori # sudoku game
        atomix # puzzle game
      ]);
    systemPackages = with pkgs; [
      gnome.adwaita-icon-theme
      gnomeExtensions.appindicator
      gnomeExtensions.blur-my-shell
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
        banner = "Welcome!";
      };
      desktopManager.gnome.enable = true;
    };
  };
}
