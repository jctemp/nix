{
  config,
  lib,
  utils,
  ...
}: let
  cfg = config.modules.system.locale;
in {
  options.modules.system.locale = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable locale module";
    };

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

    useHardwareClockInLocalTime = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use local time for hardware clock (useful for dual-boot with Windows)";
    };
  };

  config = utils.mkIfSystemAnd (cfg.enable) {
    time = {
      timeZone = cfg.timeZone;
      hardwareClockInLocalTime = cfg.useHardwareClockInLocalTime;
    };

    services.timesyncd.enable = true;

    i18n = {
      defaultLocale = cfg.defaultLocale;
      supportedLocales = [
        "${cfg.defaultLocale}/UTF-8"
        "${cfg.extraLocale}/UTF-8"
        "en_GB.UTF-8/UTF-8"
      ];

      extraLocaleSettings = let
        extraLocale = cfg.extraLocale;
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
