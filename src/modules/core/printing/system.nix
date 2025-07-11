{
  config,
  pkgs,
  lib,
  ctx,
  ...
}: let
  cfg = config.module.core.printing;
in {
  options.module.core.printing = {
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

  config = lib.mkIf cfg.enable {
    environment.systemPackages = 
      cfg.packages
      ++ lib.optionals ctx.gui cfg.packagesWithGUI;

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
  };
}