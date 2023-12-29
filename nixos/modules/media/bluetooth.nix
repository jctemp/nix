{
  config,
  lib,
  ...
}: let
  cfg = config.host.bluetooth;
in {
  imports = [];

  options.host.bluetooth = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Enable bluetooth support. It makes the default bluetooth controller
        available to the system. Additional settings are added to support
        modern bluetooth devices. Blueman is used for managing paired devices.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      # Required for modern headsets
      settings = {General = {Enable = "Source,Sink,Media,Socket";};};
    };
    services.blueman.enable = true;
  };
}
