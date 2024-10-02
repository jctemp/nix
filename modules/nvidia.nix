{
  config,
  pkgs,
  ...
}: {
  imports = [./opengl.nix];

  hardware.nvidia = {
    open = false;
    modesetting.enable = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  services.xserver.videoDrivers = ["nvidia"];
  virtualisation.docker.enableNvidia = false;
}
