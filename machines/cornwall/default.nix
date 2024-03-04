{
  lib,
  ...
}: {
  imports = [./hardware-configuration.nix];

  hosts = {
    nvidia = {
      enable = true;
      open = false;
      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
    virtualisation = {
      docker.enable = true;
      libvirt.enable = true;
    };
  };
}
