{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./locale.nix
    ./networking.nix
  ];

  nix = {
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
    settings = {
      # See https://jackson.dev/post/nix-reasonable-defaults/
      connect-timeout = 5;
      log-lines = 25;
      min-free = 128000000; # 128MB
      max-free = 1000000000; # 1GB

      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
      keep-outputs = true;
      trusted-users = ["@wheel"];

      nix.settings.substituters = [
        "https://nix-community.cachix.org"
      ];
      nix.settings.trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };

  virtualisation = {
    vmVariantWithBootLoader = {
      virtualisation.forwardPorts = [
        {
          from = "host";
          host.port = 8888;
          guest.port = 80;
        }
      ];
      diskSize = 32768;
      memorySize = 8192;
      cores = 2;
    };

    vmVariant = {
      virtualisation.forwardPorts = [
        {
          from = "host";
          host.port = 8888;
          guest.port = 80;
        }
      ];
      diskSize = 32768;
      memorySize = 8192;
      cores = 2;
    };
  };

  environment.systemPackages = [
    pkgs.curl
    pkgs.git
    pkgs.tree
    pkgs.wget
    pkgs.vim
  ];

  fonts.packages = [
    pkgs.dejavu_fonts
    pkgs.cm_unicode
    pkgs.libertine
    pkgs.roboto
    pkgs.noto-fonts
    # pkgs.nerdfonts
  ];
}
