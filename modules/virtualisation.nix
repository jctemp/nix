{
  config,
  pkgs,
  lib,
  users,
  ulib,
  ...
}: let
  cfg = config.module.virtualisation;
in {
  options.module.virtualisation = {
    enable = lib.mkOption {
      default = true;
      defaultText = "true";
      description = "Whether to enable the module.";
      type = lib.types.bool;
    };
    kubernetes = lib.mkOption {
      # TODO: integrate kubernetes
      default = null;
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;

    virtualisation.docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };

    hardware.nvidia-container-toolkit = lib.mkIf config.module.rendering.nvidia {
      enable = true;
      mount-nvidia-executables = true;
    };
    environment.systemPackages = [pkgs.libguestfs];
    users.users = ulib.populate users "extraGroups" ["docker" "libvirtd"];
  };
}
