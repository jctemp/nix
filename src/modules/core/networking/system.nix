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
    tcp.optimize = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Apply TCP optimizations";
    };

    networkManager.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use NetworkManager instead of systemd-networkd";
    };

    wireless.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable wireless networking";
    };

    ssh = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = !ctx.gui;
        description = "Enable SSH daemon";
      };

      banner = lib.mkOption {
        type = lib.types.str;
        default = ''
          █▄ █ █ ▀▄▀ █▀█ █▀▀
          █ ▀█ █ █ █ █▄█ ▄▄█
        '';
        description = "SSH login banner";
      };
    };

    firewall = {
      extraTcpPorts = lib.mkOption {
        type = lib.types.listOf lib.types.port;
        default = [];
        description = "Additional TCP ports to open";
      };

      extraUdpPorts = lib.mkOption {
        type = lib.types.listOf lib.types.port;
        default = [];
        description = "Additional UDP ports to open";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages =
      [
        pkgs.dnsutils
        pkgs.inetutils
        pkgs.mtr
        pkgs.tcpdump
      ]
      ++ lib.optionals cfg.wireless.enable [
        pkgs.wirelesstools
        pkgs.iw
      ]
      ++ cfg.packages
      ++ lib.optionals ctx.gui cfg.packagesWithGUI;

    networking = {
      networkmanager.enable = cfg.networkManager.enable;
      useNetworkd = !cfg.networkManager.enable;
      wireless.enable = cfg.wireless.enable && !cfg.networkManager.enable;
      nameservers = ["1.1.1.1" "8.8.8.8"]; # TODO: custom dns remains

      firewall = {
        enable = true;
        allowedTCPPorts = cfg.firewall.extraTcpPorts;
        allowedUDPPorts = cfg.firewall.extraUdpPorts;
      };
      nftables.enable = true;
    };

    services.resolved = lib.mkIf cfg.networkManager.enable {
      enable = true;
      dnssec = "allow-downgrade";
      domains = ["~."];
      fallbackDns = ["1.1.1.1" "9.9.9.9"]; # TODO: custom dns remains
    };

    boot.kernel.sysctl = lib.mkIf cfg.tcp.optimize {
      "net.ipv4.tcp_fastopen" = 3;
      "net.netfilter.nf_conntrack_max" = 131072;
      "net.core.rmem_max" = 16777216;
      "net.core.wmem_max" = 16777216;
      "net.ipv4.tcp_rmem" = "4096 87380 16777216";
      "net.ipv4.tcp_wmem" = "4096 65536 16777216";
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.ipv4.tcp_syncookies" = 1;
      "net.ipv4.tcp_tw_reuse" = 1;
    };

    services.openssh = lib.mkIf cfg.ssh.enable {
      enable = true;
      openFirewall = true;
      inherit (cfg.ssh) banner;
      settings = {
        KbdInteractiveAuthentication = false;
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        X11Forwarding = false;
      };
      hostKeys = let
        persistPath =
          if config.module.core.persistence.persistPath == null
          then "/persist"
          else config.module.core.persistence.persistPath;
      in [
        {
          path = "${persistPath}/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
        {
          path = "${persistPath}/ssh/ssh_host_rsa_key";
          type = "rsa";
          bits = 4096;
        }
      ];
    };
  };
}