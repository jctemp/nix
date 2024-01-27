{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.host.windowing;
in {
  imports = [];

  options.host.windowing = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable windowing support";
    };

    hidpi = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable HiDPI support";
    };

    wayland = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Wayland support";
    };
  };

  config = lib.mkIf cfg.enable {
    services.xserver = {
      enable = true;
      layout = "us";
      desktopManager.gnome.enable = true;
      displayManager = {
        defaultSession = "gnome";
        gdm.enable = true;
        gdm.wayland = cfg.wayland;
      };
    };

    environment.systemPackages = with pkgs; [
      gnomeExtensions.appindicator
      gnomeExtensions.blur-my-shell
      gnomeExtensions.forge
      gnomeExtensions.vitals
    ];

    console = lib.mkIf cfg.hidpi {
      font = "${pkgs.terminus_font}/share/consolefonts/ter-v32n.psf.gz";
      earlySetup = true;
    };

    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        ocl-icd
        intel-compute-runtime
      ];
    };
  };
}
