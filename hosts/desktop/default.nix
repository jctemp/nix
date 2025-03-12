{
  ...
}: {

  # Host specification for disk setup
  modules.hostSpec = {
    device = "/dev/nvme0n1";
    loader = "systemd";
    kernelPackage = "default";
  };

  # Enable key modules
  modules = {
    # Enable full desktop environment
    desktop = {
      enable = true;
      environment = "gnome";
    };

    # Hardware support
    hardware = {
      audio.enable = true;
      bluetooth.enable = true;
      nvidia.enable = true;
    };

    # Core services
    services = {
      printing.enable = true;
      sshd.enable = true;
      fail2ban.enable = false;
    };

    # Security features
    security = {
      yubikey.enable = true;
    };

    # Virtualization support
    virtualisation = {
      containers.enable = true;
      libvirt.enable = true;
    };

    # Networking setup
    networking = {
      useNetworkManager = true;
      optimizeTcp = true;
      enableWireless = true;
    };

    # Locale settings
    locale = {
      timeZone = "Europe/Berlin";
      defaultLocale = "en_US.UTF-8";
      extraLocale = "de_DE.UTF-8";
    };
  };

  # Power management
  powerManagement.enable = true;
  services.thermald.enable = true;
}
