{
  pkgs,
  config,
  lib,
  utils,
  ctx,
  ...
}: let
  cfg = config.modules.system.audio;

  sharedOptions = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable audio module";
    };

    backend = lib.mkOption {
      type = lib.types.enum ["pipewire" "pulseaudio"];
      default = "pipewire";
      description = "Audio backend to use";
    };

    jack.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable JACK support";
    };
  };

  # System-specific options
  systemOptions = {
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Extra audio packages to install system-wide";
    };
  };

  # User-specific options
  userOptions = {
    defaultVolume = lib.mkOption {
      type = lib.types.int;
      default = 30;
      description = "Default audio volume (0-100)";
    };
  };
in {
  options.modules.system.audio =
    sharedOptions
    // (utils.mkIfSystem systemOptions)
    // (utils.mkIfUser userOptions);

  config = lib.mkMerge [
    (utils.mkIfSystemAnd (cfg.enable) {
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
    })
    (utils.mkIfHomeAnd (cfg.enable) {
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
        ];

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
    })
  ];
}
