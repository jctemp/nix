{
  config,
  lib,
  ctx,
  ...
}: let
  cfg = config.module.core.locale;
in {
  options.module.core.locale = {
    timeZone = lib.mkOption {
      type = lib.types.str;
      default = "Europe/Berlin";
      description = "System timezone";
    };

    defaultLocale = lib.mkOption {
      type = lib.types.str;
      default = "en_US.UTF-8";
      description = "System default locale";
    };

    extraLocale = lib.mkOption {
      type = lib.types.str;
      default = "de_DE.UTF-8";
      description = "Additional locale for specific formats";
    };

    keyboardLayout = lib.mkOption {
      type = lib.types.str;
      default = "us";
      description = "Console keyboard layout";
    };

    useHardwareClockInLocalTime = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use local time for hardware clock";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = 
      cfg.packages
      ++ lib.optionals ctx.gui cfg.packagesWithGUI;

    time = {
      inherit (cfg) timeZone;
      hardwareClockInLocalTime = cfg.useHardwareClockInLocalTime;
    };

    services.timesyncd.enable = true;

    i18n = {
      inherit (cfg) defaultLocale;

      extraLocaleSettings = let
        inherit (cfg) extraLocale;
      in {
        LC_ADDRESS = extraLocale;
        LC_IDENTIFICATION = extraLocale;
        LC_MEASUREMENT = extraLocale;
        LC_MONETARY = extraLocale;
        LC_NAME = extraLocale;
        LC_NUMERIC = extraLocale;
        LC_PAPER = extraLocale;
        LC_TELEPHONE = extraLocale;
        LC_TIME = extraLocale;
      };
    };

    console.keyMap = cfg.keyboardLayout;
  };
}