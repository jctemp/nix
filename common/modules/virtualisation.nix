{
  config,
  lib,
  username,
  ...
}: {
  imports = [];

  options.hosts.virtualisation = {
    docker.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Docker";
    };
    libvirt.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable libvirt";
    };
  };

  config = {
    virtualisation.libvirtd.enable = config.hosts.virtualisation.libvirt.enable;
    programs.virt-manager.enable = config.hosts.virtualisation.libvirt.enable;

    virtualisation.docker = {
      inherit (config.hosts.virtualisation.docker) enable;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
      enableNvidia = config.hosts.nvidia.enable;
    };

    users.users.${username}.extraGroups =
      (
        if config.hosts.virtualisation.docker.enable
        then ["docker"]
        else []
      )
      ++ (
        if config.hosts.virtualisation.libvirt.enable
        then ["libvirt"]
        else []
      );
  };
}
