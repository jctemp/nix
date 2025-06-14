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
    applications = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Web applications to install for user";
    };

    browsers = {
      chrome = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable Chrome browser";
        };
        package = lib.mkOption {
          type = lib.types.package;
          default = pkgs.google-chrome;
        };
      };

      firefox = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable Firefox browser";
        };
        package = lib.mkOption {
          type = lib.types.package;
          default = pkgs.firefox;
        };
      };
    };

    defaultBrowser = lib.mkOption {
      type = lib.types.enum ["chrome" "firefox"];
      default = "chrome";
      description = "Default browser (chromium or firefox)";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      cfg.applications
      ++ (
        lib.optionals (ctx.gui && cfg.browsers.chrome.enable) [
          cfg.browsers.chrome.package
        ]
        ++ lib.optionals (ctx.gui && cfg.browsers.firefox.enable) [
          cfg.browsers.firefox.package
        ]
      );
  };

  xdg.mimeApps = lib.mkIf ctx.gui {
    enable = true;
    defaultApplications = let
      browserDesktop =
        if cfg.defaultBrowser == "firefox"
        then "firefox.desktop"
        else if cfg.defaultBrowser == "chrome" && cfg.browsers.chrome.package == pkgs.google-chrome
        then "google-chrome.desktop"
        else "chromium-browser.desktop";
    in {
      "text/html" = browserDesktop;
      "x-scheme-handler/http" = browserDesktop;
      "x-scheme-handler/https" = browserDesktop;
      "x-scheme-handler/about" = browserDesktop;
      "x-scheme-handler/unknown" = browserDesktop;
    };
  };
}
