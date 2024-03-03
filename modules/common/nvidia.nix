{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.hosts.nvidia;
in {
  imports = [];

  options.hosts.nvidia = {
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
      inherit (cfg) open prime;
      # Useful and required for wayland compositors
      modesetting.enable = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    services.xserver.videoDrivers = ["nvidia"];
  };
}
