{
  config,
  pkgs,
  lib,
  ctx,
  ...
}: let
  cfg = config.module.core.security;
in {
  options.module.core.security = {
    yubikey.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable YubiKey support";
    };

    fail2ban = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable fail2ban intrusion prevention";
      };

      maxRetry = lib.mkOption {
        type = lib.types.int;
        default = 5;
        description = "Maximum retry attempts before ban";
      };

      banTime = lib.mkOption {
        type = lib.types.str;
        default = "12h";
        description = "Ban duration";
      };
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      environment.systemPackages =
        [
          pkgs.gnupg
          pkgs.gpgme
          pkgs.libfido2
        ]
        ++ cfg.packages
        ++ lib.optionals ctx.gui cfg.packagesWithGUI;

      programs.gnupg.agent = {
        enable = true;
        pinentryPackage = pkgs.pinentry-curses;
        enableSSHSupport = cfg.yubikey.enable;
        settings = lib.mkIf cfg.yubikey.enable {
          default-cache-ttl = 60;
          max-cache-ttl = 120;
          ttyname = "$GPG_TTY";
        };
      };

      programs.fuse.userAllowOther = true;
    }

    (lib.mkIf cfg.yubikey.enable {
      environment.systemPackages = with pkgs; [
        yubioath-flutter
        yubikey-manager
        yubikey-personalization
        pcsctools
        (writeShellScriptBin "reset-gpg-yubikey" ''
          ${pkgs.gnupg}/bin/gpg-connect-agent "scd serialno" "learn --force" /bye
        '')
      ];

      programs.yubikey-touch-detector.enable = true;
      programs.ssh.startAgent = lib.mkForce false;
      services.pcscd.enable = true;
      services.udev = {
        enable = true;
        packages = [pkgs.yubikey-personalization];
      };

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

    (lib.mkIf cfg.fail2ban.enable {
      services.fail2ban = {
        enable = true;
        maxretry = cfg.fail2ban.maxRetry;
        bantime = cfg.fail2ban.banTime;
        bantime-increment = {
          enable = true;
          multipliers = "1 2 4 8 16 32 64";
          maxtime = "168h";
          overalljails = true;
        };
      };
    })
  ]);
}