{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.module.core.virtualisation;
in {
  options.module.core.virtualisation = {
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Extra packages to install system-wide";
    };

    libvirt.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable libvirt for VM management";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        environment.systemPackages = cfg.extraPackages;
      }

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
    ]
  );
}
