{
  config,
  pkgs,
  lib,
  ...
}: let
  hasNvidiaGpu = builtins.any (
    gpu:
      (gpu.vendor.hex or "") == "10de"
  ) (config.facter.report.hardware.graphics_card or []);
in {
  options.module.hardware.nvidia = {
    enable =
      lib.mkEnableOption "NVIDIA graphics support"
      // {
        default = hasNvidiaGpu;
        defaultText = "hardware dependent";
      };
  };

  config = lib.mkIf config.module.hardware.nvidia.enable {
    nixpkgs.config.allowUnfree = true;

    hardware.nvidia = {
      open = false;
      modesetting.enable = true;
      nvidiaSettings = true;
    };

    services.xserver.videoDrivers = ["nvidia"];

    hardware.nvidia-container-toolkit = lib.mkIf config.module.core.virtualisation.containers.enable {
      enable = true;
      mount-nvidia-executables = true;
    };

    hardware.graphics.extraPackages = [
      pkgs.nvidia-vaapi-driver
    ];

    # TODO: add configuration to automagically configure DGPU
  };
}
