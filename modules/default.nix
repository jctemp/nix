{pkgs, lib, ...}: {
  imports = [
    ./common
    ./desktop
    ./multimedia
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
    kernelPackages = pkgs.zfs.latestCompatibleLinuxPackages;
    supportedFilesystems = lib.mkForce ["btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" "zfs"];
    loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        device = "nodev";
        useOSProber = true;
        configurationLimit = 10;
      };
    };
  };

  time.timeZone = "Europe/Berlin";
  # RTC time to local time such that Windows can cope
  time.hardwareClockInLocalTime = true;

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

      # Defaults
      pkgs.curl
      pkgs.git
      pkgs.ripgrep
      pkgs.tree
      pkgs.wget

      # Yubikey
      pkgs.yubico-piv-tool
      pkgs.yubikey-manager
      pkgs.yubikey-manager-qt
      pkgs.yubikey-personalization
      pkgs.yubikey-personalization-gui
      pkgs.yubikey-touch-detector
      pkgs.yubioath-flutter

      # GPG
      pkgs.gnupg
      pkgs.pinentry

      # Further tools
      pkgs.paperkey
      pkgs.pcsctools
    ];
    shellInit = init;
    interactiveShellInit = init;
  };

  programs = {
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

  fonts.packages = [
    pkgs.dejavu_fonts
    pkgs.cm_unicode
    pkgs.libertine
    pkgs.roboto
    pkgs.noto-fonts
  ];
}
