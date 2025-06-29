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
      [
        # Core media tools
        pkgs.ffmpeg
        pkgs.imagemagick
        pkgs.exiftool
      ]
      ++ cfg.packages
      ++ lib.optionals ctx.gui (
        [
          pkgs.vlc
        ]
        ++ lib.optionals cfg.categories.audio.enable [
          pkgs.spotify
          pkgs.audacity
        ]
        ++ lib.optionals cfg.categories.video.enable [
          pkgs.obs-studio
        ]
        ++ lib.optionals cfg.categories.graphics.enable [
          pkgs.gimp
        ]
        ++ lib.optionals cfg.categories.modeling.enable [
          pkgs.blender_4_4
          pkgs.freecad
        ]
        ++ cfg.packagesWithGUI
      );
  };
}
