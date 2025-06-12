{
  pkgs,
  config,
  lib,
  utils,
  ctx,
  ...
}: let
  cfg = config.modules.system.printing;

  sharedOptions = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = ctx.gui;
      description = "Enable printing module";
    };
  };

  # System-specific options (only used in system context)
  systemOptions = {
    networkDiscovery.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable network printer discovery via Avahi";
    };

    extraDrivers = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Additional printer drivers";
    };
  };

  # User-specific options (only used in user context)
  userOptions = {
    applications = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Printing applications to install for user";
    };
  };
in {
  options.modules.system.printing =
    sharedOptions
    // (utils.mkIfSystem systemOptions)
    // (utils.mkIfUser userOptions);

  config = lib.mkMerge [
    (utils.mkIfSystemAnd (cfg.enable) {
      services.printing = {
        enable = true;
        openFirewall = true;
        drivers = with pkgs;
          [gutenprint]
          ++ cfg.extraDrivers;
      };

      services.avahi = lib.mkIf cfg.networkDiscovery.enable {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
        publish = {
          enable = true;
          userServices = true;
        };
      };
    })
    (utils.mkIfHomeAnd (cfg.enable) {
      home.packages = lib.mkIf cfg.enableGuiApps (
        cfg.applications
        ++ (with pkgs; [
          system-config-printer # Printer configuration GUI
          evince # FOSS document viewer
        ])
      );

      dconf.settings = lib.mkIf (ctx.gui && config.modules.core.gnome.enable) {
        "org/gnome/desktop/interface" = {
          gtk-print-preview-command = "${pkgs.evince}/bin/evince --preview %s";
        };
      };
    })
  ];
}
