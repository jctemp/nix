{pkgs, ...}: {
  home.packages = with pkgs; [
    # GNOME desktop environment
    gnome-tweaks
    gnome-shell-extensions
    gnome-session
    gnome-extension-manager

    # GNOME extensions
    gnomeExtensions.forge
    gnomeExtensions.appindicator
    gnomeExtensions.dash-to-dock
    gnomeExtensions.blur-my-shell
    gnomeExtensions.vitals
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.switch-x11-wayland-default-session

    # Themes and icons
    whitesur-gtk-theme
    whitesur-icon-theme
    papirus-icon-theme

    # GUI applications - Development
    gitkraken

    # GUI applications - Productivity
    keepassxc
    zotero
    libreoffice

    # GUI applications - Media & Graphics
    spotify
    blender_4_3
    freecad
    gimp
    inkscape
    vlc

    # GUI applications - System utilities
    gnome-system-monitor
    gnome-disk-utility
    gnome-calculator
    gnome-calendar

    # File managers
    nautilus

    # Archive managers
    file-roller
  ];

  # GTK configuration
  gtk = {
    enable = true;
    theme = {
      name = "WhiteSur-Dark";
      package = pkgs.whitesur-gtk-theme;
    };
    iconTheme = {
      name = "WhiteSur-dark";
      package = pkgs.whitesur-icon-theme;
    };
    cursorTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  # Qt configuration for consistent theming
  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };

  # dconf settings for GNOME
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      gtk-theme = "WhiteSur-Dark";
      icon-theme = "WhiteSur-dark";
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
        "appindicatorsupport@rgcjonas.gmail.com"
        "dash-to-dock@micxgx.gmail.com"
        "blur-my-shell@aunetx"
        "Vitals@CoreCoding.com"
        "clipboard-indicator@tudmotu.com"
      ];
    };

    "org/gnome/shell/extensions/user-theme" = {
      name = "WhiteSur-Dark";
    };
  };

  # XDG settings for application defaults
  xdg = {
    enable = true;

    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "google-chrome.desktop";
        "x-scheme-handler/http" = "google-chrome.desktop";
        "x-scheme-handler/https" = "google-chrome.desktop";
        "x-scheme-handler/about" = "google-chrome.desktop";
        "x-scheme-handler/unknown" = "google-chrome.desktop";
        "application/pdf" = "org.gnome.Evince.desktop";
        "image/jpeg" = "org.gnome.eog.desktop";
        "image/png" = "org.gnome.eog.desktop";
        "text/plain" = "org.gnome.TextEditor.desktop";
      };
    };

    # User directories
    userDirs = {
      enable = true;
      createDirectories = true;
      desktop = "$HOME/Desktop";
      documents = "$HOME/Documents";
      download = "$HOME/Downloads";
      music = "$HOME/Music";
      pictures = "$HOME/Pictures";
      videos = "$HOME/Videos";
      templates = "$HOME/Templates";
      publicShare = "$HOME/Public";
    };
  };

  # Session variables for GUI applications
  home.sessionVariables = {
    GTK_THEME = "WhiteSur-Dark";
    QT_STYLE_OVERRIDE = "adwaita-dark";

    XDG_CURRENT_DESKTOP = "GNOME";
    XDG_SESSION_DESKTOP = "gnome";
    XDG_SESSION_TYPE = "x11";
  };
}
