{
  config,
  pkgs,
  ...
}: {
  imports = [];

  hardware = {
    nvidia = {
      open = false;
      modesetting.enable = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    nvidia-container-toolkit.enable = true;

    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      setLdLibraryPath = true;
      extraPackages = [pkgs.mesa.drivers];
    };
  };

  services.xserver.videoDrivers = ["nvidia"];
}
