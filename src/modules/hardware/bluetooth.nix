{
  config,
  lib,
  ...
}: let
  hasBluetoothDevice = builtins.length (config.facter.report.hardware.bluetooth or []) > 0;
in {
  options.modules.hardware.bluetooth = {
    enable =
      lib.mkEnableOption "Bluetooth support"
      // {
        default = hasBluetoothDevice;
        defaultText = "hardware dependent";
      };
  };

  config = lib.mkIf config.modules.hardware.bluetooth.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = "true";
          KernelExperimental = "true";
          ReconnectAttempts = "7";
          ReconnectIntervals = "1,2,4,8,16,32,64";
        };
      };
    };
  };
}
