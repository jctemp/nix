{
  config,
  pkgs,
  lib,
  ctx,
  ...
}: let
  cfg = config.module.core.networking;
in {
  options.module.core.networking = {
    applications = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "networking applications to install for user";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs;
      [
        nmap
        netcat
        iperf3
        dig
      ]
      ++ lib.optionals ctx.gui ([
          wireshark
        ]
        ++ cfg.applications);
  };
}
