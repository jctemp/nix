{
  config,
  pkgs,
  lib,
  ctx,
  ...
}: let
  cfg = config.module.core.virtualisation;
in {
  config = lib.mkIf cfg.enable {
    home.packages =
      lib.optionals (cfg.containers.enable && cfg.containers.backend == "podman") [
        pkgs.podman-tui
      ]
      ++ lib.optionals (cfg.libvirt.enable && ctx.gui) [
          pkgs.gnome-boxes
      ]
      ++ cfg.packages
      ++ lib.optionals ctx.gui cfg.packagesWithGUI;
  };
}