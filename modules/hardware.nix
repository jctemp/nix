{
  config,
  pkgs,
  lib,
  ...
}: {
  # Define hardware module options
  options.modules.hardware = {
    audio.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable audio support with PipeWire";
    };

    bluetooth.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Bluetooth support";
    };

    nvidia.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable NVIDIA drivers";
    };
  };

  # Implementation of the hardware modules
  config = lib.mkMerge [
    # Basic hardware settings for all systems
    {
      hardware.enableRedistributableFirmware = true;
      services.fwupd.enable = true;
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };
    }

    # Audio configuration
    (lib.mkIf config.modules.hardware.audio.enable {
      hardware.pulseaudio.enable = false;
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa = {
          enable = true;
          support32Bit = true;
        };
        pulse.enable = true;
        jack.enable = true;
      };
    })

    # Bluetooth configuration
    (lib.mkIf config.modules.hardware.bluetooth.enable {
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
        settings = {
          General = {
            Enable = "Source,Sink,Media,Socket";
            Experimental = "true";
            KernelExperimental = "true";
            ReconnectAttempts = "7";
            ReconnectIntervals = "1,2,4,8,16,32,64";
          };
        };
      };
    })

    # NVIDIA configuration
    (lib.mkIf config.modules.hardware.nvidia.enable {
      nixpkgs.config.allowUnfree = true;
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
    })
  ];
}
