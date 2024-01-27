{
  config,
  hostName,
  users,
  ...
}: let
  userNames = map (user: user.userName) users;
in {
  imports = [
    ./hardware-configuration.nix
  ];

  config.host = {
    # COMMON

    locale = {
      time = {
        timeZone = "Europe/Berlin";
        hardwareClockInLocalTime = false;
      };
      i18n = {
        default = "en_US.UTF-8";
        extraLocale = "de_DE.UTF-8";
      };
    };

    networking = {
      inherit hostName;
      enable = true;
      users = userNames;
    };

    windowing.enable = false;

    # HARDWARE

    nvidia.enable = false;

    # MEDIA

    audio.enable = false;
    bluetooth.enable = false;
    printing.enable = false;

    # SECURITY

    gpg = {
      enable = true;
      sshSupport = true;
    };

    yubikey.enable = true;

    # VIRTUALISATION

    docker = {
      enable = true;
      rootless = true;
      nvidia = false;
      users = userNames;
    };

    libvirt.enable = false;
  };
}
