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
      audio = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable audio applications";
      };

      video = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable video applications";
      };

      graphics = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable graphics applications";
      };

      modeling = lib.mkOption {
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
        ++ lib.optionals cfg.categories.audio [
          pkgs.spotify
          pkgs.audacity
        ]
        ++ lib.optionals cfg.categories.video [
          pkgs.obs-studio
        ]
        ++ lib.optionals cfg.categories.graphics [
          pkgs.gimp
        ]
        ++ lib.optionals cfg.categories.modeling [
          pkgs.blender
          pkgs.freecad
        ]
        ++ cfg.packagesWithGUI
      );
  };
}
}
