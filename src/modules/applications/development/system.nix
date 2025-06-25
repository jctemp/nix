{
  config,
  lib,
  pkgs,
  ctx,
  ...
}: let
  cfg = config.module.applications.development;
in {
  config = lib.mkIf cfg.enable {
    environment.systemPackages =
      [
        pkgs.curl
        pkgs.wget
        pkgs.vim
        pkgs.helix
      ]
      ++ cfg.packages
      ++ lib.optionals ctx.gui cfg.packagesWithGUI;

    programs.git = {
      enable = true;
      lfs.enable = true;
      prompt.enable = true;
      config = {
        color.ui = true;
        grep.lineNumber = true;
        init.defaultBranch = "main";
        core = {
          autocrlf = "input";
          editor = "${pkgs.vim}/bin/vim";
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
