{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.module.applications.media;
in {
  options.module.core.media = {
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Extra media packages to install system-wide";
    };

    enableCodecs = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable multimedia codecs";
    };
  };
  config = lib.mkIf cfg.enable {
    nixpkgs.config = lib.mkIf cfg.enableCodecs {
      allowUnfree = true;
    };

    environment.systemPackages = with pkgs;
      lib.optionals cfg.enableCodecs [
        # Audio/Video codecs
        gstreamer
        gst_all_1.gstreamer
        gst_all_1.gst-plugins-base
        gst_all_1.gst-plugins-good
        gst_all_1.gst-plugins-bad
        gst_all_1.gst-plugins-ugly
        gst_all_1.gst-libav

        # Hardware acceleration
        intel-media-driver
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
      ]
      ++ cfg.extraPackages;
  };
}
