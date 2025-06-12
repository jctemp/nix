{
  config,
  lib,
  pkgs,
  utils,
  ctx,
  ...
}: let
  cfg = config.modules.system.virtualisation;

  sharedOptions = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable virtualisation module";
    };
  };

  # System-specific options (only used in system context)
  systemOptions = {
    containers = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable container virtualization";
      };

      backend = lib.mkOption {
        type = lib.types.enum ["podman" "docker"];
        default = "podman";
        description = "Container backend to use";
      };
    };

    libvirt.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable libvirt for VM management";
    };
  };

  # User-specific options (only used in user context)
  userOptions = {
    applications = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Virtualisation applications to install for user";
    };
  };
in {
  options.modules.system.virtualisation =
    sharedOptions
    // (utils.mkIfSystem systemOptions)
    // (utils.mkIfUser userOptions);

  config = lib.mkMerge [
    (utils.mkIfSystemAnd (cfg.enable) lib.mkMerge [
      (lib.mkIf cfg.containers.enable {
        virtualisation = {
          containers.enable = true;
          oci-containers.backend = cfg.containers.backend;

          podman = lib.mkIf (cfg.containers.backend == "podman") {
            enable = true;
            dockerCompat = true;
            defaultNetwork.settings.dns_enabled = true;
          };

          docker = lib.mkIf (cfg.containers.backend == "docker") {
            enable = true;
          };
        };

        environment.systemPackages = with pkgs;
          [
            dive
          ]
          ++ lib.optionals (cfg.containers.backend == "podman") [
            podman-compose
          ]
          ++ lib.optionals (cfg.containers.backend == "docker") [
            docker-compose
          ];
      })

      # libvirt for VMs
      (lib.mkIf cfg.libvirt.enable {
        virtualisation.libvirtd.enable = true;
        programs.virt-manager.enable = true;

        environment.systemPackages = with pkgs; [
          virt-manager
          libguestfs
          spice-gtk
          win-virtio
        ];
      })
    ])
    (utils.mkIfHomeAnd (cfg.enable) {
      home.packages =
        (with pkgs;
          lib.optionals cfg.containers.enable [
            podman-tui
          ])
        ++ lib.optionals ctx.gui cfg.applications;
    })
  ];
}
