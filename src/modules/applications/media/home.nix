{
  config,
  pkgs,
  lib,
  ctx,
  ...
}: let
  cfg = config.module.applications.media;
in {
  options.module.applications.media = {
    applications = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Media applications to install for user";
    };

    categories = {
      audio.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable audio applications";
      };

      video.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable video applications";
      };

      graphics.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable graphics applications";
      };

      modeling.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable 3D modeling applications";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      cfg.applications
      ++ [
        pkgs.ffmpeg
        pkgs.imagemagick
        pkgs.exiftool
      ]
      ++ lib.optionals ctx.gui [
        pkgs.vlc
      ]
      ++ lib.optionals (ctx.gui && cfg.categories.audio.enable) [
        pkgs.spotify
        pkgs.audacity
      ]
      ++ lib.optionals (ctx.gui && cfg.categories.video.enable) [
        pkgs.obs-studio
      ]
      ++ lib.optionals (ctx.gui && cfg.categories.graphics.enable) [
        pkgs.gimp
      ]
      ++ lib.optionals (ctx.gui && cfg.categories.modeling.enable) [
        pkgs.blender_4_4
        pkgs.freecad
      ];
  };
}
