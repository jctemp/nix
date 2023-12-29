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
    hardware = {
      opengl = {
        enable = true;
        driSupport = true;
        driSupport32Bit = true;
        extraPackages = with pkgs; [
          rocmPackages.clr.icd
          intel-compute-runtime
          intel-media-driver
          ocl-icd
        ];
      };
      nvidia = {
        modesetting.enable = true;
        nvidiaSettings = true;
        open = true;
        package = config.boot.kernelPackages.nvidiaPackages.stable;
        # prime = {
        #   offload = {
        #     enable = true;
        #     enableOffloadCmd = true;
        #   };
        #   intelBusId = "PCI:0:2:0";
        #   nvidiaBusId = "PCI:1:0:0";
        # };
      };
    };

    services.xserver.videoDrivers = ["nvidia"];
  };
}
