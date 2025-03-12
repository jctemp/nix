{
  config,
  pkgs,
  lib,
  ...
}: {
  # Define virtualization module options
  options.modules.virtualisation = {
    containers = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable container virtualization (Docker/Podman)";
      };
    };

    libvirt = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable libvirt for virtual machine management";
      };
    };
  };

  # Implement virtualization configurations
  config = lib.mkMerge [
    # Container virtualization (Docker/Podman)
    (lib.mkIf config.modules.virtualisation.containers.enable {
      virtualisation = {
        containers.enable = true;
        oci-containers.backend = "podman";
        podman = {
          enable = true;
          dockerCompat = true; # Enable Docker compatibility
          defaultNetwork.settings.dns_enabled = true;
        };
      };

      # Add container-related packages
      environment.systemPackages = with pkgs; [
        dive # Tool for exploring Docker image layers
        podman-tui # Terminal UI for Podman
        podman-compose # Compose for Podman
      ];
    })

    # libvirt for virtual machine management
    (lib.mkIf config.modules.virtualisation.libvirt.enable {
      virtualisation.libvirtd.enable = true;
      programs.virt-manager.enable = true;

      # Add VM-related packages
      environment.systemPackages = with pkgs; [
        virt-manager
        libguestfs # Tools for accessing and modifying VM disk images
        spice-gtk # SPICE client
        win-virtio # Windows VirtIO drivers
      ];
    })

    # VM-specific options for testing configurations (only applies when running as a VM)
    {
      virtualisation.vmVariant = {
        virtualisation.forwardPorts = [
          {
            from = "host";
            host.port = 8888;
            guest.port = 80;
          }
        ];

        # Hardware configuration for VMs
        diskSize = 32768; # 32 GB
        memorySize = 8192; # 8 GB
        cores = 4;
      };
    }
  ];
}
