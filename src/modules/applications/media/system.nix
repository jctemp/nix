{
  config,
  lib,
  pkgs,
  ctx,
  ...
}: let
  cfg = config.module.applications.media;
in {
  config = lib.mkIf cfg.enable {
    nixpkgs.config.allowUnfree = true;

    environment.systemPackages =
      [
        pkgs.ffmpeg
        pkgs.imagemagick
      ]
      ++ cfg.packages
      ++ lib.optionals ctx.gui (
        [
          # Hardware acceleration
          pkgs.intel-media-driver
          pkgs.vaapiIntel
          pkgs.vaapiVdpau
          pkgs.libvdpau-va-gl
        ]
        ++ cfg.packagesWithGUI
      );
  };
}