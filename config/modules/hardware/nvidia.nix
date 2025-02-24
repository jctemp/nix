{
  config,
  pkgs,
  lib,
  ...
}: {
  options.modules.hardware.nvidia.enable = lib.mkOption {
    default = false;
    type = lib.types.bool;
    description = ''
      Add standard NVIDIA drivers to the system.
    '';
  };

  config = lib.mkIf config.modules.hardware.nvidia.enable {
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "nvidia-x11"
        "nvidia-settings"
      ];

    hardware.nvidia = {
      open = false;
      modesetting.enable = true;
      nvidiaSettings = true;
    };

    services.xserver.videoDrivers = ["nvidia"];

    hardware.nvidia-container-toolkit = {
      enable = true;
      mount-nvidia-executables = true;
    };

    hardware.graphics.extraPackages = [
      pkgs.nvidia-vaapi-driver
    ];
  };
}
