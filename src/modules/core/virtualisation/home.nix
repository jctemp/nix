{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.module.core.virtualisation;
in {
  options.module.core.virtualisation = {
    applications = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "virtualisation applications to install for user";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      (with pkgs;
        lib.optionals cfg.containers.enable [
          podman-tui
        ])
      ++ cfg.applications;
  };
}
