{
  config,
  pkgs,
  lib,
  ctx,
  ...
}: let
  cfg = config.module.applications.terminal.zellij;
in {
  options.module.applications.terminal.zellij = {
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
    home.packages = 
      cfg.packages
      ++ lib.optionals ctx.gui cfg.packagesWithGUI;

    programs.zellij = {
      enable = true;
      enableBashIntegration = cfg.enableShellIntegration;
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