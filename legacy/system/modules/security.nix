{
  config,
  pkgs,
  lib,
  ...
}: {
  # Define security module options
  options.modules.security = {
    yubikey = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable YubiKey support";
      };
    };

    # Option for firewall customization
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

  # Implement security configurations
  config = lib.mkMerge [
    # Basic security packages for all systems
    {
      environment.systemPackages = with pkgs;
        [
          gnupg
          gpgme
          libfido2
        ]
        ++ lib.optionals config.modules.security.yubikey.enable [
          yubioath-flutter
          yubikey-manager
          yubikey-personalization
          pcsctools
          (writeShellScriptBin "reset-gpg-yubikey" ''
            ${pkgs.gnupg}/bin/gpg-connect-agent "scd serialno" "learn --force" /bye
          '')
        ];

      # Enable FUSE for user mounts
      programs.fuse.userAllowOther = true;

      # Configure GPG agent
      programs.gnupg.agent = {
        enable = true;
        pinentryPackage = pkgs.pinentry-curses;
        enableSSHSupport = config.modules.security.yubikey.enable;
        settings = lib.mkIf config.modules.security.yubikey.enable {
          default-cache-ttl = 60;
          max-cache-ttl = 120;
          ttyname = "$GPG_TTY";
        };
      };
    }

    # YubiKey specific configurations
    (lib.mkIf config.modules.security.yubikey.enable {
      programs.yubikey-touch-detector.enable = true;
      programs.ssh.startAgent = lib.mkForce false;

      # YubiKey services
      services.pcscd.enable = true;
      services.udev = {
        enable = true;
        packages = [pkgs.yubikey-personalization];
      };

      # YubiKey shell initialization
      environment = {
        shellInit = ''
          export GPG_TTY="$(tty)"
          ${pkgs.gnupg}/bin/gpg-connect-agent /bye
          export SSH_AUTH_SOCK=$(${pkgs.gnupg}/bin/gpgconf --list-dirs agent-ssh-socket)
          ${pkgs.gnupg}/bin/gpgconf --launch gpg-agent
        '';
        interactiveShellInit = ''
          export GPG_TTY="$(tty)"
          ${pkgs.gnupg}/bin/gpg-connect-agent /bye
          export SSH_AUTH_SOCK=$(${pkgs.gnupg}/bin/gpgconf --list-dirs agent-ssh-socket)
          ${pkgs.gnupg}/bin/gpgconf --launch gpg-agent
        '';
      };
    })

    # Basic firewall configuration
    {
      networking.firewall = {
        enable = true;
        # Automatically open ports for enabled services
        allowedTCPPorts =
          config.modules.security.firewall.extraTcpPorts;
        allowedUDPPorts =
          config.modules.security.firewall.extraUdpPorts;
      };
    }
  ];
}
