{lib}: rec {
  # Generate a consistent host identifier for ZFS and other services
  hostIdentifier = hostname:
    builtins.substring 0 8 (builtins.hashString "md5" hostname);

  # Create a set of firewall rules from a list of ports
  makeNetworkRules = {
    tcp ? [],
    udp ? [],
  }: {
    allowedTCPPorts = tcp;
    allowedUDPPorts = udp;
    allowedTCPPortRanges = [];
    allowedUDPPortRanges = [];
    extraCommands = "";
  };

  # Generate complete firewall rules for common services
  generateFirewallRules = {config, ...}: let
    # Common service ports
    webPorts = [80 443];
    sshPort = 22;
    printingPorts = [631 5353];
    mediaServerPorts = [1900 5353 8096 8920];

    # Determine which ports should be open based on enabled services
    webEnabled = config.services.nginx.enable || config.services.caddy.enable;
    sshEnabled = config.services.openssh.enable;
    printingEnabled = config.modules.services.printing.enable or false;
    mediaEnabled = config.services.jellyfin.enable or false;

    # Combine all required ports
    tcpPorts =
      (lib.optionals webEnabled webPorts)
      ++ (lib.optionals sshEnabled [sshPort])
      ++ (lib.optionals printingEnabled printingPorts)
      ++ (lib.optionals mediaEnabled mediaServerPorts);

    udpPorts =
      (lib.optionals printingEnabled [5353])
      ++ (lib.optionals mediaEnabled [1900 5353]);
  in
    makeNetworkRules {
      tcp = tcpPorts;
      udp = udpPorts;
    };

  # Create a reverse proxy configuration for local services
  reverseProxyConfig = services: let
    # Generate config for a single service
    mkServiceConfig = name: {
      port,
      ssl ? true,
      extraConfig ? "",
    }: ''
      ${name}.local {
        ${
        if ssl
        then "tls internal"
        else ""
      }
        reverse_proxy localhost:${toString port}
        ${extraConfig}
      }
    '';
  in
    lib.concatStringsSep "\n\n" (
      lib.mapAttrsToList mkServiceConfig services
    );
}
