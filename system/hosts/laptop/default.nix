{pkgs, ...}: {
  # Host specification for disk setup
  modules.hostSpec = {
    device = "/dev/nvme0n1";
    loader = "systemd";
    kernelPackage = "zen"; # Use zen kernel for better laptop performance
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
      bluetooth.enable = true;
      nvidia.enable = true;
    };

    # Core services
    services = {
      audio.enable = true;
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

  # Laptop-specific packages (only packages not in modules/default.nix)
  environment.systemPackages = with pkgs; [
    # Laptop-specific tools
    powertop
    acpi

    # Nvidia Optimus support
    (writeShellScriptBin "nvidia-offload" ''
      export __NV_PRIME_RENDER_OFFLOAD=1
      export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export __VK_LAYER_NV_optimus=NVIDIA_only
      exec -a "$0" "$@"
    '')
  ];

  powerManagement = {
    enable = true;
    powertop.enable = true;
  };

  hardware.nvidia.prime = {
    offload = {
      enable = true;
      enableOffloadCmd = true;
    };
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };
}
