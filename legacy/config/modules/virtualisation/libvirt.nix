{
  config,
  pkgs,
  lib,
  ...
}: {
  options.modules.virtualisation.libvirt.enable = lib.mkOption {
    default = true;
    type = lib.types.bool;
    description = ''
      Enable libvirt.
    '';
  };

  config = lib.mkIf config.modules.virtualisation.libvirt.enable {
    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;

    environment.systemPackages = [
      pkgs.dive
      pkgs.libguestfs
    ];
  };
}
