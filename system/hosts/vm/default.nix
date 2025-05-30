{
  pkgs,
  lib,
  ...
}: {
  # Host specification for disk setup
  modules.hostSpec = {
    disk = "/dev/sda";
    loader = "grub";
  };

  # Enable key modules for server functionality
  modules = {
    # No desktop environment for server VM
    desktop.enable = false;

    # Minimal hardware support
    hardware = {
      bluetooth.enable = false;
      nvidia.enable = false;
    };

    # Server services
    services = {
      audio.enable = false;
      printing.enable = false;
      sshd.enable = true;
      fail2ban.enable = true;
    };

    # Security features
    security = {
      yubikey.enable = false;
      firewall = {
        extraTcpPorts = [22]; # SSH only
      };
    };

    # Container support but no desktop virtualization
    virtualisation = {
      containers.enable = true;
      libvirt.enable = false;
    };

    # Server-focused network settings
    networking = {
      useNetworkManager = true;
      optimizeTcp = true;
      enableWireless = false;
    };

    # Locale settings
    locale = {
      timeZone = "UTC"; # Use UTC for servers
      defaultLocale = "en_US.UTF-8";
      extraLocale = "en_US.UTF-8"; # Consistent locale throughout
    };
  };

  # Server-specific packages (only packages not in modules/default.nix)
  environment.systemPackages = with pkgs; [
    # Server monitoring
    iotop
    iftop

    # Network tools
    mtr
    tcpdump
    iperf3
  ];

  # Server tuning
  boot = {
    kernelParams = [
      "noatime"
      "elevator=none"
    ];
  };

  # Disable power management for VM
  powerManagement.enable = false;

  # Enable cloud-init for VM deployments
  services.cloud-init = {
    enable = true;
    network.enable = true;
  };

  # Minimize documentation for server
  documentation = {
    enable = lib.mkDefault false;
    man.enable = true;
  };
}
