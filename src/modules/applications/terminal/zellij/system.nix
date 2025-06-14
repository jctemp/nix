{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.module.applications.zellij;
in {
  options.module.core.zellij = {
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
