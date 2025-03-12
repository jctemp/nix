{
  config,
  lib,
  ...
}: {
  options.modules.hardware.audio.enable = lib.mkOption {
    default = false;
    type = lib.types.bool;
    description = ''
      Add the pipewire services to the system for audio.
    '';
  };

  config = lib.mkIf config.modules.hardware.audio.enable {
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
  };
}
