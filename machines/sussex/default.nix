{...}: {
  imports = [./hardware-configuration.nix];
  hosts.nvidia = {
    enable = true;
    open = true;
  };
}
