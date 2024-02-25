{...}: {
  imports = [./hardware-configuration.nix];
  hosts = {
    nvidia = {
      enable = true;
      open = true;
    };
    virtualisation = {
      docker.enable = true;
      libvirt.enable = true;
    };
  };
}
