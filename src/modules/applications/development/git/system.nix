{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.module.applications.git;
in {
  options.module.core.git = {
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Extra git packages to install system-wide";
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = cfg.extraPackages;
    programs.git = {
      enable = true;
      lfs.enable = true;
      prompt.enable = true;
      config = {
        color.ui = true;
        grep.lineNumber = true;
        init.defaultBranch = "canon";
        core = {
          autocrlf = "input";
          editor = "${pkgs.helix}/bin/hx";
        };
        diff = {
          mnemonicprefix = true;
          rename = "copy";
        };
        url = {
          "https://github.com/" = {
            insteadOf = [
              "gh:"
              "github:"
            ];
          };
        };
      };
    };
  };
}
