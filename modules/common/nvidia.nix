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
    prime = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Enable NVIDIA PRIME";
    };
  };

  config = lib.mkIf cfg.enable {
    nix = {
      settings = {
        substituters = [
          "https://cuda-maintainers.cachix.org"
        ];
        trusted-public-keys = [
          "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
        ];
      };
    };

    environment.systemPackages = lib.mkIf (cfg.prime == {}) [
      (pkgs.writeShellScriptBin "nvidia-offload" ''
        export __NV_PRIME_RENDER_OFFLOAD=1
        export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
        export __GLX_VENDOR_LIBRARY_NAME=nvidia
        export __VK_LAYER_NV_optimus=NVIDIA_only
        exec -a "$0" "$@"
      '')
    ];

    hardware.nvidia = {
      inherit (cfg) prime;
      open = false;
      modesetting.enable = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    services.xserver.videoDrivers = ["nvidia"];
  };
}
