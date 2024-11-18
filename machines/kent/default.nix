{device, ...}: {
  imports = [
    ./hardware-configuration.nix
  ];

  module = {
    boot = {
      inherit device;
      canTouchEfiVariables = false;
      loader = "grub";
    };
    multimedia = {
      enable = false;
      bluetoothSupport = false;
    };
    rendering = {
      renderer = false;
      nvidia = false;
      opengl = true;
    };
    privacy = {
      enable = true;
      supportYubikey = false;
    };
    virtualisation = {
      enable = true;
      kubernetes = null;
    };
  };

  services = {
    cloud-init.network.enable = true;
    openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        KbdInteractiveAuthentication = true;
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        X11Forwarding = true;
      };
      hostKeys = [
        {
          path = "/persist/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
        {
          path = "/persist/ssh/ssh_host_rsa_key";
          type = "rsa";
          bits = 4096;
        }
      ];
    };
  };
}
