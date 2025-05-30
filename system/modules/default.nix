{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./options.nix
    ./hardware.nix
    ./services.nix
    ./security.nix
    ./desktop.nix
    ./virtualisation.nix
    ./networking.nix
    ./locale.nix
  ];

  config = {
    # Nix configuration
    nix = {
      # Use flakes and the new command-line interface
      settings = {
        experimental-features = "nix-command flakes";
        auto-optimise-store = true;
        keep-outputs = true;
        trusted-users = ["@wheel"];

        # Resource management
        connect-timeout = 5;
        log-lines = 25;
        min-free = 128000000; # 128MB
        max-free = 1000000000; # 1GB
      };
    };

    # Core system settings
    boot.tmp.cleanOnBoot = true;
    boot.kernelModules = ["tcp_bbr"];
    system.stateVersion = "24.11";
    system.rebuild.enableNg = true;

    # Essential system packages
    environment.systemPackages = lib.flatten [
      [
        pkgs.bat
        pkgs.bottom
        pkgs.uutils-coreutils-noprefix
        pkgs.dust
        pkgs.dysk
        pkgs.fselect
        pkgs.hyperfine
        pkgs.just
        pkgs.mprocs
        pkgs.ripgrep
        pkgs.xh
      ]
      [
        pkgs.curl
        pkgs.git
        pkgs.jq
        pkgs.pciutils
        pkgs.tree
        pkgs.unzip
        pkgs.usbutils
        pkgs.vim
        pkgs.zip
      ]
    ];

    # Basic font selection
    fonts.packages = with pkgs; [
      nerd-fonts.symbols-only
      nerd-fonts.ubuntu
      nerd-fonts.ubuntu-mono
      nerd-fonts.roboto-mono
    ];

    # Documentation settings
    documentation = {
      enable = true;
      dev.enable = true;
      doc.enable = false;
      info.enable = false;
      man.enable = true;
      nixos.enable = true;
    };
  };
}
