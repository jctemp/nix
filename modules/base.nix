{
  pkgs,
  userName,
  hostName,
  ...
}: {
  # ==== [ Nix ] ==============================================================

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
    optimise = {
      automatic = true;
    };
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
      trusted-users = ["root" userName];
    };
  };

  # ==== [ Networking ] =======================================================

  networking = {
    inherit hostName;
    hostId = builtins.substring 0 8 (builtins.hashString "md5" hostName);
    wireless.enable = false;
    networkmanager.enable = true;
  };

  # ==== [ Internationalisation and Time ] ====================================

  time = {
    timeZone = "Europe/Berlin";
    hardwareClockInLocalTime = true; # for windoof
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = let
      extraLocale = "de_DE.UTF-8";
    in {
      LC_ADDRESS = extraLocale;
      LC_IDENTIFICATION = extraLocale;
      LC_MEASUREMENT = extraLocale;
      LC_MONETARY = extraLocale;
      LC_NAME = extraLocale;
      LC_NUMERIC = extraLocale;
      LC_PAPER = extraLocale;
      LC_TELEPHONE = extraLocale;
      LC_TIME = extraLocale;
    };
  };

  # ==== [ MISC ] =============================================================

  fonts.packages = [
    pkgs.dejavu_fonts
    pkgs.cm_unicode
    pkgs.libertine
    pkgs.roboto
    pkgs.noto-fonts
    pkgs.nerdfonts
  ];

  users.users.${userName}.extraGroups = ["networkmanager"];
  environment.systemPackages = [
    pkgs.curl
    pkgs.git
    pkgs.ripgrep
    pkgs.tree
    pkgs.wget
    pkgs.vim
  ];
}
