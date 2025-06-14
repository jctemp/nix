{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.module.applications.terminal.zellij;
in {
  options.module.applications.terminal.zellij = {
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Extra zellij packages to install system-wide";
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages =
      cfg.extraPackages
      ++ (
        with pkgs; [
          zellij
        ]
      );
  };
}
