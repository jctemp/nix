{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.module.applications.zellij;
in {
  options.module.core.zellij = {
    applications = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Zellij applications to install for user";
    };

    theme = lib.mkOption {
      type = lib.types.str;
      default = "ayu_dark";
      description = "Zellij color theme";
    };

    enableShellIntegration = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Shell integration";
    };

    simplifiedUi = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use simplified UI";
    };

    copyCommand = lib.mkOption {
      type = lib.types.str;
      default = "${pkgs.xclip}/bin/xclip -sel clipboard";
      description = "Command to copy to clipboard";
    };

    showStartupTips = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Show startup tips";
    };

    extraConfig = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Additional Zellij configuration";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = cfg.applications;
    programs.zellij = {
      enable = true;
      inherit (cfg) enableBashIntegration;
      settings =
        {
          simplified_ui = cfg.simplifiedUi;
          inherit (cfg) theme;
          show_startup_tips = cfg.showStartupTips;
        }
        // (lib.optionalAttrs (cfg.copyCommand != "") {
          copy_command = cfg.copyCommand;
        })
        // cfg.extraConfig;
    };
  };
}
