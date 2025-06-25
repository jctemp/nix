{
  config,
  lib,
  ...
}: let
  cfg = config.module.core.audio;
in {
  options.module.core.audio = {
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Extra audio packages to install system-wide";
    };

    jack.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable JACK support";
    };
  };

  config = lib.mkIf cfg.enable {
    security.rtkit.enable = true;
    services.pulseaudio.enable = lib.mkForce (cfg.backend == "pulseaudio");
    services.pipewire = lib.mkIf (cfg.backend == "pipewire") {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = cfg.jack.enable;
    };
    environment.systemPackages = cfg.extraPackages;
  };
}
