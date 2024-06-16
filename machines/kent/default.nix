{self, ...}: {
  imports = [
    ./hardware-configuration.nix

    "${self}/modules/base.nix"
    "${self}/modules/boot/grub.nix"
  ];

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
