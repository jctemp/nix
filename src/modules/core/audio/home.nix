{
  config,
  pkgs,
  lib,
  ctx,
  ...
}: let
  cfg = config.module.core.audio;
in {
  options.module.core.audio = {
    defaultVolume = lib.mkOption {
      type = lib.types.int;
      default = 30;
      description = "Default audio volume (0-100)";
    };

    applications = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Audio applications to install for user";
    };
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.config.allowUnfree = true;

    home.packages = with pkgs;
      [
        alsa-utils
        pulsemixer
      ]
      ++ lib.optionals (ctx.gui) [
        pavucontrol
        easyeffects
        helvum
      ]
      ++ cfg.applications;

    systemd.user.services.set-default-volume = {
      Unit = {
        Description = "Set default audio volume";
        After = ["pipewire.service" "pulseaudio.service"];
        Wants =
          if cfg.backend == "pipewire"
          then ["pipewire.service"]
          else ["pulseaudio.service"];
      };
      Service = {
        Type = "oneshot";
        ExecStart =
          if cfg.backend == "pipewire"
          then "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ ${toString cfg.defaultVolume}%"
          else "${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ ${toString cfg.defaultVolume}%";
        RemainAfterExit = true;
      };
      Install = {
        WantedBy = ["default.target"];
      };
    };
  };
}
