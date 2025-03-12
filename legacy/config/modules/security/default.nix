{pkgs, ...}: {
  imports = [
    ./yubikey.nix
  ];

  environment.systemPackages = [
    pkgs.gnupg
    pkgs.gpgme
    pkgs.libfido2
  ];

  programs = {
    # Filesystem in Userspace; secure method for non privileged users to
    # create and mount their own filesystem
    fuse.userAllowOther = true;
    gnupg.agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry-curses;
    };
  };
}
