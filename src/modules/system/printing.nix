{
  pkgs,
  config,
  lib,
  utils,
  ...
}: let
  cfg = config.modules.system.printing;
in {
  options.modules.system.printing = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable printing module";
    };

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
      # TODO: add application
    })
  ];
}
