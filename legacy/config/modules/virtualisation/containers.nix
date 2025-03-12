{
  config,
  pkgs,
  lib,
  ...
}: {
  options.modules.virtualisation.containers.enable = lib.mkOption {
    default = true;
    type = lib.types.bool;
    description = ''
      Enable container virtualisation.
    '';
  };

  config = lib.mkIf config.modules.virtualisation.containers.enable {
    virtualisation = {
      containers.enable = true;
      oci-containers.backend = "podman";
      podman = {
        enable = true;
        dockerCompat = true;
        defaultNetwork.settings.dns_enabled = true;
      };
    };

    environment.systemPackages = [
      pkgs.dive
      pkgs.podman-tui
      pkgs.podman-compose
    ];
  };
}
