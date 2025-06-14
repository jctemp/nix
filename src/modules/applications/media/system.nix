{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.module.applications.media;
in {
  options.module.applications.media = {
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
        # Hardware acceleration
        intel-media-driver
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
      ]
      ++ cfg.extraPackages;
  };
}
