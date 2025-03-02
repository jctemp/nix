{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.modules.services.routing;

  generateCaddyfile = let
    localEntries = lib.concatStringsSep "\n\n" (lib.mapAttrsToList (name: port: ''
        ${name}.local {
          tls internal

          reverse_proxy localhost:${toString port}
        }
      '')
      cfg.local);
  in ''
    # Local services with SSL certificates
    ${localEntries}

    # Optional catch-all for any undefined service
    :80 {
      respond "Service not found" 404
    }
  '';
in {
  options.modules.services.routing = {
    enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = ''
        Caddy for local service access
      '';
    };

    local = lib.mkOption {
      type = lib.types.attrsOf lib.types.int;
      description = "Mapping of service names to local ports";
      default = {};
      example = {
        ollama = 4242;
        grafana = 3000;
      };
    };

    extraConfig = lib.mkOption {
      type = lib.types.str;
      description = "Extra configuration to append to the Caddyfile";
      default = "";
      example = ''
        example.local {
          respond "Hello, world!"
        }
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.caddy = {
      enable = true;
      configFile = pkgs.writeText "Caddyfile" (
        generateCaddyfile
        + (lib.optionalString (cfg.extraConfig != "") "\n\n# Extra configuration\n${cfg.extraConfig}")
      );
    };

    # Set up local DNS resolution
    networking.extraHosts = lib.concatStringsSep "\n" (lib.mapAttrsToList (
        name: port: "127.0.0.1 ${name}.local"
      )
      cfg.local);

    # Install mkcert for development SSL certificates
    environment.systemPackages = with pkgs; [
      mkcert
    ];

    # TODO: fix installation
    system.activationScripts.setupLocalCA = ''
      # Create required directories
      mkdir -p /var/lib/mkcert

      # Set CAROOT to a system-wide location
      export CAROOT=/var/lib/mkcert

      # Setup mkcert local CA if not already done
      if [ ! -f $CAROOT/rootCA.pem ]; then
        echo "Setting up local certificate authority for development..."
        ${pkgs.mkcert}/bin/mkcert -install || echo "Warning: mkcert installation failed, SSL certificates may not be trusted"
      fi
    '';
  };
}
