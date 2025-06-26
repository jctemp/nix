{pkgs, ...}: {
  imports = [./profiles/optimised.nix];
  
  # Laptop-specific overrides
  module = {
    core = {
      boot = {
        loader = "systemd";
        kernelPackage = "default";
      };
      
      persistence = {
        enable = true;
        disk = "/dev/nvme0n1"; 
        persistPath = "/persist";
      };
      
      audio = {
        backend = "pipewire";
        jack.enable = false; 
      };
      
      networking = {
        networkManager.enable = true;
        wireless.enable = true;
        tcp.optimize = true;
        ssh.enable = false;
      };
      
      locale = {
        timeZone = "Europe/Berlin";
        defaultLocale = "en_US.UTF-8";
        extraLocale = "de_DE.UTF-8";
        keyboardLayout = "us";
      };
      
      security = {
        yubikey.enable = true;
        fail2ban.enable = false;
      };
      
      virtualisation = {
        containers = {
          enable = true;
          backend = "podman";
        };
        libvirt.enable = false; 
      };
      
      users = {
        administrators = ["tmpl"];
        primaryUser = "tmpl";
      };
    };

    applications = {
      development.enable = true;
    };
  };

  # Laptop-specific hardware and power optimizations
  # TODO: Add power management, battery optimization, etc.
  # Use facter to determine if the modules should be enabled

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