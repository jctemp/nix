{
  config,
  pkgs,
  username,
  ...
}: {
  imports = [
    ./modules/networking.nix
    ./modules/nvidia.nix
    ./modules/system-tools.nix
  ];

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
      trusted-users = ["root"];
    };
  };

  boot = {
    supportedFilesystems = ["ext4" "btrfs" "xfs" "ntfs" "fat" "vfat" "exfat"];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  time.timeZone = "Europe/Berlin";

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

  environment = let
    # Informs the environment that we are using GPG agent for SSH
    init = ''
      export GPG_TTY="$(tty)"
      gpg-connect-agent /bye
      export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
      gpgconf --launch gpg-agent
    '';
  in {
    systemPackages = [
      # GPG w/ Yubikey (Multiple keys)
      (pkgs.writeShellScriptBin "gpg-reset-yubikey-id" ''
        echo "Reset gpg to make new key available."
        set -x
        set -e
        ${pkgs.psmisc}/bin/killall gpg-agent
        rm -r ~/.gnupg/private-keys-v1.d/
        echo "Now the new key should work."
      '')

      # Yubikey
      pkgs.yubico-piv-tool
      pkgs.yubikey-manager
      pkgs.yubikey-manager-qt
      pkgs.yubikey-personalization
      pkgs.yubikey-personalization-gui
      pkgs.yubikey-touch-detector
      pkgs.yubioath-flutter

      # GPG itself
      pkgs.gnupg
      pkgs.pinentry

      # Backup Keys
      pkgs.paperkey
      pkgs.pgpdump
      pkgs.parted
      pkgs.cryptsetup

      # Other useful tools
      pkgs.cfssl
      pkgs.pcsctools

      # libvirt stuff
      pkgs.libguestfs
    ];
    shellInit = init;
    interactiveShellInit = init;
  };

  virtualisation = {
    libvirtd.enable = true;
    docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
      enableNvidia = config.hosts.nvidia.enable;
    };
  };

  programs = {
    virt-manager.enable = true;
    ssh.startAgent = false;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  services = {
    udev.packages = [pkgs.yubikey-personalization];
    pcscd.enable = true;
  };

  users.users.${username}.extraGroups = ["docker" "libvirt"];
}
