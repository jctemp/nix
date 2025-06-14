{
  config,
  lib,
  ...
}: let
  cfg = config.module.applications.terminal.ghostty;
in {
  options.module.applications.terminal.ghostty = {
    applications = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Ghostty applications to install for user";
    };

    theme = lib.mkOption {
      type = lib.types.str;
      default = "ayu";
      description = "Ghostty color theme";
    };

    fontSize = lib.mkOption {
      type = lib.types.int;
      default = 12;
      description = "Font size for terminal";
    };

    font = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Font family (empty for default)";
    };

    maximize = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Start maximized";
    };

    enableShellIntegration = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Shell integration";
    };

    extraConfig = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Additional Ghostty configuration";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = cfg.applications;
    programs.ghostty = {
      enable = true;
      enableBashIntegration = cfg.enableShellIntegration;
      settings =
        {
          inherit (cfg) theme;
          font-size = cfg.fontSize;
          inherit (cfg) maximize;
        }
        // (lib.optionalAttrs (cfg.font != "") {
          font-family = cfg.font;
        })
        // cfg.extraConfig;
    };
  };
}
