{
  config,
  pkgs,
  lib,
  ctx,
  ...
}: let
  cfg = config.module.core.virtualisation;
in {
  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        environment.systemPackages = 
          cfg.packages
          ++ lib.optionals ctx.gui cfg.packagesWithGUI;
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

      (lib.mkIf cfg.libvirt.enable {
        virtualisation.spiceUSBRedirection.enable = true;

        virtualisation.libvirtd = {
          enable = true;
          qemu = {
            swtpm.enable = true;
            ovmf.packages = [ pkgs.OVMFFull.fd ];
          };
        };
        programs.virt-manager.enable = true;

        environment.systemPackages = with pkgs; [
          dnsmasq
          libguestfs
          phodav
          spice-gtk
          virt-manager
          win-virtio
        ];
      })
    ]
  );
}