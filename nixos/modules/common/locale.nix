{
  config,
  lib,
  ...
}: let
  cfg = config.host.locale;
in {
  imports = [];

  options.host.locale = {
    time = {
      timeZone = lib.mkOption {
        type = lib.types.str;
        default = "Europe/Berlin";
        description = "Time zone of the host";
      };
      hardwareClockInLocalTime = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether the hardware clock is in local time";
      };
    };
    i18n = {
      default = lib.mkOption {
        type = lib.types.str;
        default = "en_US.UTF-8";
        description = "Default locale";
      };
      extraLocale = lib.mkOption {
        type = lib.types.str;
        default = "de_DE.UTF-8";
        description = "Extra locale";
      };
    };
  };

  config = {
    time = {
      timeZone = cfg.time.timeZone;
      hardwareClockInLocalTime = cfg.time.hardwareClockInLocalTime;
    };

    i18n = {
      defaultLocale = cfg.i18n.default;
      extraLocaleSettings = let
        extraLocale = cfg.i18n.extraLocale;
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
  };
}
