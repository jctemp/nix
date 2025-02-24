{
  config,
  lib,
  ...
}: {
  options.modules.services.sshd.enable = lib.mkOption {
    default = true;
    type = lib.types.bool;
    description = ''
      Add a SSH daemon to the host.
    '';
  };

  config = lib.mkIf config.modules.services.sshd.enable {
    services.openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        KbdInteractiveAuthentication = false;
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        X11Forwarding = false;
      };
      hostKeys = [
        {
          path = "${config.hostSpec.safePath}/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
        {
          path = "${config.hostSpec.safePath}/ssh/ssh_host_rsa_key";
          type = "rsa";
          bits = 4096;
        }
      ];
    };
  };
}
