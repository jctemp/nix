{
  config,
  pkgs,
  lib,
  ...
}: {
  options.modules.services.printing.enable = lib.mkOption {
    default = true;
    type = lib.types.bool;
    description = ''
      Enable printing.
    '';
  };

  config = lib.mkIf config.modules.services.printing.enable {
    services = {
      # Required to queue a job
      printing = {
        enable = true;
        openFirewall = true;
        drivers = [
          pkgs.gutenprint
          pkgs.epson-escpr
          pkgs.epson-escpr2
        ];
      };

      # Required to send the job over the network
      avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true; # required for UDP 5353
        publish = {
          enable = true;
          userServices = true;
        };
      };
    };
  };
}
