{
  pkgs,
  yubikeySupport ? false,
  ...
}: {
  # Informs the environment that we are using GPG agent for SSH
  environment = {
    shellInit =
      if yubikeySupport
      then ''
        export GPG_TTY="$(tty)"
        gpg-connect-agent /bye
        export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
        gpgconf --launch gpg-agent
      ''
      else "";
    interactiveShellInit =
      if yubikeySupport
      then ''
        export GPG_TTY="$(tty)"
        gpg-connect-agent /bye
        export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
        gpgconf --launch gpg-agent
      ''
      else "";
  };

  programs = {
    fuse.userAllowOther = true;
    ssh.startAgent = false;
    gnupg.agent = {
      enable = yubikeySupport;
      enableSSHSupport = yubikeySupport;
    };
  };

  services =
    if yubikeySupport
    then {
      udev.packages = [pkgs.yubikey-personalization];
      pcscd.enable = true;
    }
    else {};

  environment.systemPackages =
    [
      pkgs.gnupg
      pkgs.pinentry
    ]
    ++ (
      if yubikeySupport
      then [
        # GPG w/ Yubikey (Multiple keys)
        (pkgs.writeShellScriptBin "gpg-reset-yubikey-id" ''
          echo "Reset gpg to make new key available."
          set -x
          set -e
          ${pkgs.psmisc}/bin/killall gpg-agent
          rm -r ~/.gnupg/private-keys-v1.d/
          echo "Now the new key should work."
        '')

        # Yubikey
        pkgs.yubico-piv-tool
        pkgs.yubikey-manager
        pkgs.yubikey-manager-qt
        pkgs.yubikey-personalization
        pkgs.yubikey-personalization-gui
        pkgs.yubikey-touch-detector
        pkgs.yubioath-flutter

        # Further tools
        pkgs.paperkey
        pkgs.pcsctools
      ]
      else []
    );
}
