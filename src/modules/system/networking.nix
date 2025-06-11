{
  pkgs,
  config,
  lib,
  utils,
  ...
}: let
  cfg = config.modules.system.networking;
in {
  options.modules.system.networking = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable networking module";
    };

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
        default = false;
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

  config = lib.mkMerge [
    (utils.mkIfSystemAnd (cfg.enable) {
      networking = {
        networkmanager.enable = cfg.networkManager.enable;
        useNetworkd = !cfg.networkManager.enable;

        wireless.enable = cfg.wireless.enable && !cfg.networkManager.enable;
        nameservers = ["1.1.1.1" "8.8.8.8"]; # TODO: make this configurable + proxy options

        # Firewall
        firewall = {
          enable = true;
          allowedTCPPorts = cfg.firewall.extraTcpPorts;
          allowedUDPPorts = cfg.firewall.extraUdpPorts;
        };
        nftables.enable = true;
      };

      # DNS resolution (when using NetworkManager)
      services.resolved = lib.mkIf cfg.networkManager.enable {
        enable = true;
        dnssec = "allow-downgrade";
        domains = ["~."];
        fallbackDns = ["1.1.1.1" "9.9.9.9"]; # TODO: update DNS if configurable
      };

      # Basic network tools
      environment.systemPackages = with pkgs;
        [
          dnsutils
          inetutils
          mtr
          nmap
          tcpdump
        ]
        ++ lib.optionals
        cfg.wireless.enable [
          wirelesstools
          iw
        ];

      boot.kernel.sysctl = lib.mkIf cfg.tcp.optimize {
        # TCP Fast Open
        "net.ipv4.tcp_fastopen" = 3;
        # Increase connection tracking table size
        "net.netfilter.nf_conntrack_max" = 131072;
        # Increase the maximum receive/transmit buffers
        "net.core.rmem_max" = 16777216;
        "net.core.wmem_max" = 16777216;
        # Increase TCP buffer limits
        "net.ipv4.tcp_rmem" = "4096 87380 16777216";
        "net.ipv4.tcp_wmem" = "4096 65536 16777216";
        # Enable BBR congestion control
        "net.core.default_qdisc" = "fq";
        "net.ipv4.tcp_congestion_control" = "bbr";
        # Protect against SYN flood attacks
        "net.ipv4.tcp_syncookies" = 1;
        # Reuse sockets in TIME_WAIT state
        "net.ipv4.tcp_tw_reuse" = 1;
      };

      services.openssh = {
        enable = true;
        openFirewall = true;
        banner = cfg.ssh.banner;
        settings = {
          KbdInteractiveAuthentication = false;
          PasswordAuthentication = false;
          PermitRootLogin = "no";
          X11Forwarding = false;
        };
        hostKeys = let
          persistPath =
            config.modules.system.persistence.persistPath or lib.warn
            "persistPath is unset; using /persist as default" "/persist";
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
    })
    (utils.mkIfHomeAnd (cfg.enable) {
      })
  ];
}
