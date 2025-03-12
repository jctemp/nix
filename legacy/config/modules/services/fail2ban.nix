{
  config,
  lib,
  ...
}: {
  options.modules.services.fail2ban.enable = lib.mkOption {
    default = true;
    type = lib.types.bool;
    description = ''
      Add a ban rules for bad people
    '';
  };

  config = lib.mkIf config.modules.services.fail2ban.enable {
    services.fail2ban = {
      enable = true;
      maxretry = 5;
      bantime = "12h";
      bantime-increment = {
        enable = true;
        # formula = "ban.Time * math.exp(float(ban.Count+1)*banFactor)/math.exp(1*banFactor)";
        multipliers = "1 2 4 8 16 32 64";
        maxtime = "168h";
        overalljails = true;
      };
    };
  };
}
