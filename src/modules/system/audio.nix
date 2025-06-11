{
  pkgs,
  config,
  lib,
  utils,
  ctx,
  ...
}: let
  cfg = config.modules.system.audio;
in {
  options.modules.system.audio = {
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
    })
    (utils.mkIfHomeAnd (cfg.enable) {
      nixpkgs.config.allowUnfree = true;
      home.packages = utils.optionalsGUI (with pkgs; [
        spotify
      ]);
    })
  ];
}
