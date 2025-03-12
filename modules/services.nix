{
  config,
  pkgs,
  lib,
  ...
}: {
  # Define service options
  options.modules.services = {
    # SSH configuration
    sshd = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable SSH daemon";
      };
    };

    # Printing service
    printing = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable printing support";
      };
    };

    # fail2ban
    fail2ban = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable fail2ban for intrusion prevention";
      };
    };
  };

  # Implement configurations based on options
  config = lib.mkMerge [
    {
      # SSH daemon configuration
      services.openssh = lib.mkIf config.modules.services.sshd.enable {
        enable = true;
        openFirewall = true;
        banner = ''
          █▄ █ █ ▀▄▀ █▀█ █▀▀
          █ ▀█ █ █ █ █▄█ ▄▄█
          ${config.system.stateVersion}
        '';
        settings = {
          KbdInteractiveAuthentication = true;
          PasswordAuthentication = false;
          PermitRootLogin = "no";
          X11Forwarding = false;
        };
        hostKeys = [
          {
            path = "${config.modules.hostSpec.safePath}/ssh/ssh_host_ed25519_key";
            type = "ed25519";
          }
          {
            path = "${config.modules.hostSpec.safePath}/ssh/ssh_host_rsa_key";
            type = "rsa";
            bits = 4096;
          }
        ];
      };
    }
    {
      # Printing configuration
      services.printing = lib.mkIf config.modules.services.printing.enable {
        enable = true;
        openFirewall = true;
        drivers = [
          pkgs.gutenprint
          pkgs.epson-escpr
          pkgs.epson-escpr2
        ];
      };

      # Avahi for printer discovery
      services.avahi = lib.mkIf config.modules.services.printing.enable {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
        publish = {
          enable = true;
          userServices = true;
        };
      };
    }
    {
      # fail2ban configuration
      services.fail2ban = lib.mkIf config.modules.services.fail2ban.enable {
        enable = true;
        maxretry = 5;
        bantime = "12h";
        bantime-increment = {
          enable = true;
          multipliers = "1 2 4 8 16 32 64";
          maxtime = "168h";
          overalljails = true;
        };
      };
    }
  ];
}
