{
  config,
  pkgs,
  lib,
  ...
}: {
  options.modules.security.yubikey.enable = lib.mkOption {
    default = true;
    type = lib.types.bool;
    description = ''
      Add YubiKey functionality to the host.
    '';
  };

  config = lib.mkIf (config.modules.security.yubikey.enable) {
    environment = let
      init = ''
        export GPG_TTY="$(tty)"
        ${pkgs.gnupg}/bin/gpg-connect-agent /bye
        export SSH_AUTH_SOCK=$(${pkgs.gnupg}/bin/gpgconf --list-dirs agent-ssh-socket)
        ${pkgs.gnupg}/bin/gpgconf --launch gpg-agent
      '';
    in {
      shellInit = init;
      interactiveShellInit = init;

      systemPackages = [
        pkgs.yubioath-flutter
        pkgs.yubikey-manager
        pkgs.yubikey-personalization
        pkgs.pcsctools
        (pkgs.writeShellScriptBin "reset-gpg-yubikey" ''
          ${pkgs.gnupg}/bin/gpg-connect-agent "scd serialno" "learn --force" /bye
        '')
      ];
    };

    programs = {
      gnupg.agent = {
        enableSSHSupport = lib.mkForce true;
        settings = {
          default-cache-ttl = 60;
          max-cache-ttl = 120;
          ttyname = "$GPG_TTY";
        };
      };
      yubikey-touch-detector.enable = true;
      ssh.startAgent = lib.mkForce false;
    };

    services = {
      pcscd.enable = true;
      udev = {
        enable = true;
        packages = [pkgs.yubikey-personalization];
      };
    };
  };
}
