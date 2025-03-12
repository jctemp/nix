{pkgs, lib, ...}: {
  imports = [
    ./hardware.nix
    ./services.nix
    ./security.nix
    ./desktop.nix
    ./virtualisation.nix
    ./networking.nix
    ./locale.nix
  ];

  # Define common options for all modules
  options.modules.hostSpec = {
    hostName = lib.mkOption {
      type = lib.types.str;
      description = "Name of the host";
    };

    device = lib.mkOption {
      type = lib.types.str;
      description = "Device path for disko";
    };

    loader = lib.mkOption {
      type = lib.types.enum ["systemd" "grub"];
      description = "Type of loader for system boot";
      default = "systemd";
    };

    safePath = lib.mkOption {
      type = lib.types.str;
      description = "The base directory for persistence";
      default = "/persist";
    };

    kernelPackage = lib.mkOption {
      type = lib.types.enum ["default" "zen" "hardened"];
      description = "Which kernel package to use";
      default = "default";
    };
  };

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

    # Essential system packages
    environment.systemPackages = with pkgs; [
      # Basic utilities
      curl
      git
      tree
      vim
      htop

      # System tools
      file
      pciutils
      usbutils

      # Archives & text processing
      unzip
      zip
      jq
      ripgrep
    ];

    # Basic font selection
    fonts.packages = with pkgs; [
      dejavu_fonts
      noto-fonts
      noto-fonts-emoji
    ];

    # Enable zsh
    programs.zsh = {
      enable = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
    };

    # Documentation settings
    documentation = {
      enable = true;
      doc.enable = false;
      info.enable = false;
      man.enable = true;
    };
  };
}
