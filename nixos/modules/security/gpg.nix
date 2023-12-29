{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.host.gpg;
in {
  imports = [];

  options.host.gpg = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Enable GPG support. This will install GPG packages with some additional tools
        for keys generation and backup.
      '';
    };

    sshSupport = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Enable SSH support for GPG agent. The SSH agent will be replaced by GPG agent
        and one can use a GPG key to authenticate to SSH servers.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment = let
      # Informs the environment that we are using GPG agent
      init = ''
        export GPG_TTY="$(tty)"
        gpg-connect-agent /bye
        export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
        gpgconf --launch gpg-agent
      '';
    in {
      systemPackages = [
        # GPG itself
        pkgs.gnupg
        pkgs.pinentry

        # Backup Keys
        pkgs.paperkey
        pkgs.pgpdump
        pkgs.parted
        pkgs.cryptsetup

        # Other useful tools
        pkgs.cfssl
        pkgs.pcsctools
      ];
      shellInit = init;
      interactiveShellInit = init;
    };

    programs = lib.mkIf cfg.sshSupport {
      ssh.startAgent = false;
      gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };
    };
  };
}
