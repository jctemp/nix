{
  config,
  pkgs,
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

    windowing = {
      enable = true;
      hidpi = true;
    };

    # HARDWARE

    nvidia = {
      enable = true;
      open = false;
      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };

    # MEDIA

    audio = {
      enable = true;
      users = userNames;
    };

    bluetooth.enable = true;

    printing = {
      enable = true;
      drivers = [pkgs.gutenprint];
    };

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
      nvidia = true;
      users = userNames;
    };

    libvirt = {
      enable = true;
      users = userNames;
    };
  };
}
