{
  config,
  lib,
  ...
}: {
  # Define locale module options
  options.modules.locale = {
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

  # Configure locale settings
  config = lib.mkMerge [
    # Time settings
    {
      time = {
        timeZone = config.modules.locale.timeZone;
        hardwareClockInLocalTime = config.modules.locale.useHardwareClockInLocalTime;
      };

      # Enable NTP time synchronization
      services.timesyncd.enable = true;
    }

    # Locale settings
    {
      i18n = {
        defaultLocale = config.modules.locale.defaultLocale;
        supportedLocales = [
          "${config.modules.locale.defaultLocale}/UTF-8"
          "${config.modules.locale.extraLocale}/UTF-8"
          "en_GB.UTF-8/UTF-8"
        ];

        # Set specific locale settings for different categories
        extraLocaleSettings = let
          extraLocale = config.modules.locale.extraLocale;
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
    }

    # Console settings
    {
      console = {
        font = "Lat2-Terminus16";
        useXkbConfig = true;
      };
    }
  ];
}
