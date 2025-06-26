{
  config,
  pkgs,
  lib,
  ctx,
  ...
}: let
  cfg = config.module.core.networking;
in {
  config = lib.mkIf cfg.enable {
    home.packages =
      [
        pkgs.nmap
        pkgs.netcat
        pkgs.iperf3
        pkgs.dig
      ]
      ++ lib.optionals ctx.gui [
        pkgs.wireshark
      ]
      ++ cfg.packages
      ++ lib.optionals ctx.gui cfg.packagesWithGUI;
  };
}