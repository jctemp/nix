{
  pkgs,
  lib,
  ...
}: {
  # WSL-specific configuration
  wsl = {
    enable = true;
    defaultUser = "tmpl";
    startMenuLaunchers = true;

    # Enable USB/IP support for accessing USB devices in WSL
    usbip.enable = true;

    interop.register = true;

    # WSL-specific configuration
    wslConf = {
      automount.root = "/mnt";
      automount.options = "metadata,umask=22,fmask=11";
      network.generateHosts = true;
      network.generateResolvConf = true;
      interop.appendWindowsPath = true;
      interop.enabled = true;
    };
  };

  # In WSL, we don't need normal disk configuration
  modules = {
    # No desktop environment
    desktop.enable = false;

    # Minimal hardware support
    hardware = {
      audio.enable = false;
      bluetooth.enable = false;
      nvidia.enable = false;
    };

    # Basic services
    services = {
      sshd.enable = true;
      fail2ban.enable = false;
      printing.enable = false;
    };

    # YubiKey support in WSL
    security = {
      yubikey.enable = true;
    };

    # Minimal container support
    virtualisation = {
      containers.enable = true;
      libvirt.enable = false;
    };

    # Locale settings
    locale = {
      timeZone = "Europe/Berlin";
      defaultLocale = "en_US.UTF-8";
    };
  };

  # WSL doesn't need boot options
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

  # Simplified filesystem for WSL
  fileSystems."/" = lib.mkForce {
    device = "none";
    fsType = "tmpfs";
    options = ["defaults" "size=4G" "mode=755"];
  };

  # No need for full persistence on WSL
  environment.persistence = lib.mkForce {};

  # WSL-specific packages (only packages not in modules/default.nix)
  environment.systemPackages = with pkgs; [
    # WSL integration
    wsl-open

    # Development tools
    gcc
    gnumake
    nodejs
    python3

    # Terminal tools
    fzf
    bat
    fd

    # Shell enhancements
    starship
    direnv
    oh-my-zsh
  ];

  # WSL performance tuning
  security.pam.loginLimits = [
    {
      domain = "*";
      type = "soft";
      item = "nofile";
      value = "16384";
    }
    {
      domain = "*";
      type = "hard";
      item = "nofile";
      value = "32768";
    }
  ];

  # Minimize documentation in WSL
  documentation = {
    enable = lib.mkDefault false;
    man.enable = true;
  };
}
