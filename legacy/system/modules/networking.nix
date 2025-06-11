{
  config,
  pkgs,
  lib,
  ...
}: {
  # Define networking module options
  options.modules.networking = {
    optimizeTcp = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Apply TCP optimizations";
    };

    useNetworkManager = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use NetworkManager instead of systemd-networkd";
    };

    useDHCP = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use DHCP for network configuration";
    };

    enableWireless = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable wireless networking";
    };
  };

  # Configure networking
  config = lib.mkMerge [
    # Basic networking setup
    {
      networking = {
        # Host attributes
        hostName = config.modules.hostSpec.hostName;
        hostId = builtins.substring 0 8 (builtins.hashString "md5" config.networking.hostName);

        # Use NetworkManager for desktop setups, systemd-networkd for servers
        networkmanager.enable = config.modules.networking.useNetworkManager;
        useNetworkd = !config.modules.networking.useNetworkManager;

        # Configure DHCP
        useDHCP = lib.mkDefault config.modules.networking.useDHCP;

        # Configure wireless networking (if not using NetworkManager)
        wireless.enable =
          config.modules.networking.enableWireless
          && !config.networking.networkmanager.enable;

        # DNS settings
        nameservers = ["1.1.1.1" "8.8.8.8"];
      };
    }

    # TCP optimizations
    (lib.mkIf config.modules.networking.optimizeTcp {
      # Kernel TCP optimizations
      boot.kernel.sysctl = {
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
    })

    # NetworkManager DNS configuration
    (lib.mkIf config.networking.networkmanager.enable {
      services.resolved = {
        enable = true;
        dnssec = "allow-downgrade";
        domains = ["~."];
        fallbackDns = ["1.1.1.1" "9.9.9.9"];
      };
    })

    # Network firewall
    {
      networking = {
        firewall.enable = true;
        nftables.enable = true;
      };
    }

    # Common network tools
    {
      environment.systemPackages = with pkgs;
        [
          dnsutils # DNS lookup utilities (dig, nslookup)
          inetutils # Basic networking tools
          mtr # Traceroute/ping combination
        ]
        ++ lib.optionals (!config.modules.desktop.enable) [
          # Additional tools for servers or non-desktop systems
          ethtool # Network interface configuration
          iperf3 # Network performance testing
          nmap # Network scanner
          tcpdump # Packet analyzer
        ]
        ++ lib.optionals config.networking.wireless.enable [
          wirelesstools # Additional wireless tools
          iw # Wireless configuration tool
        ];
    }
  ];
}
