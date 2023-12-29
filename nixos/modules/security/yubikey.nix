{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.host.yubikey;
in {
  imports = [];

  options.host.yubikey = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Enable Yubikey support. This will install the necessary packages and
        enable the pcscd service. It adds a script to reset gpg to allow
        multi-key usage.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment = let
      scripts =
        if config.host.gpg.enable
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
        ]
        else [];
    in {
      systemPackages =
        scripts
        ++ [
          pkgs.yubico-piv-tool
          pkgs.yubikey-manager
          pkgs.yubikey-manager-qt
          pkgs.yubikey-personalization
          pkgs.yubikey-personalization-gui
          pkgs.yubikey-touch-detector
          pkgs.yubioath-flutter
        ];
    };

    services = {
      udev.packages = [pkgs.yubikey-personalization];
      pcscd.enable = true;
    };
  };
}
