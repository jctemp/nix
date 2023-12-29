{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.host.nvidia;
in {
  imports = [];

  options.host.nvidia = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable NVIDIA drivers";
    };
    open = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open source drivers";
    };
    prime = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Enable NVIDIA PRIME";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "nvidia-offload" ''
        export __NV_PRIME_RENDER_OFFLOAD=1
        export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
        export __GLX_VENDOR_LIBRARY_NAME=nvidia
        export __VK_LAYER_NV_optimus=NVIDIA_only
        exec -a "$0" "$@"
      '')
    ];

    hardware.nvidia = {
      modesetting.enable = true;
      nvidiaSettings = true;
      open = cfg.open;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      prime = cfg.prime;
    };

    services.xserver.videoDrivers = ["nvidia"];
  };
}
