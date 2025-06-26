{
  config,
  lib,
  ctx,
  ...
}: let
  cfg = config.module.core.audio;
in {
  options.module.core.audio = {
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
    
    environment.systemPackages = 
      cfg.packages
      ++ lib.optionals ctx.gui cfg.packagesWithGUI;
  };
}