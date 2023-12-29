{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.host.audio;
in {
  imports = [];

  options.host.audio = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Enable audio support. It enables an audio server and adds users to the
        audio group which are specified in the users option.
      '';
    };
    users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = ''
        List of users to add to the audio group.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    hardware.pulseaudio = {
      enable = true;
      support32Bit = true;
      package = pkgs.pulseaudioFull;
    };

    users.users = builtins.foldl' (result: set: result // set) {} (
      builtins.map
      (user: {${user} = {extraGroups = ["audio"];};})
      cfg.users
    );
  };
}
