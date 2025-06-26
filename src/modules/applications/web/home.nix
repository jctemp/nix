{
  config,
  pkgs,
  lib,
  ctx,
  ...
}: let
  cfg = config.module.applications.web;
in {
  options.module.applications.web = {
    browsers = {
      chrome.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Chrome browser";
      };

      firefox.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Firefox browser";
      };
    };

    defaultBrowser = lib.mkOption {
      type = lib.types.enum ["chrome" "firefox"];
      default = "chrome";
      description = "Default browser";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      cfg.packages
      ++ lib.optionals ctx.gui (
        lib.optionals cfg.browsers.chrome [
          pkgs.google-chrome
        ]
        ++ lib.optionals cfg.browsers.firefox [
          pkgs.firefox
        ]
        ++ cfg.packagesWithGUI
      );

    xdg.mimeApps = lib.mkIf ctx.gui {
      enable = true;
      defaultApplications = let
        browserDesktop =
          if cfg.defaultBrowser == "firefox"
          then "firefox.desktop"
          else "google-chrome.desktop";
      in {
        "text/html" = browserDesktop;
        "x-scheme-handler/http" = browserDesktop;
        "x-scheme-handler/https" = browserDesktop;
        "x-scheme-handler/about" = browserDesktop;
        "x-scheme-handler/unknown" = browserDesktop;
      };
    };
  };
}