{
  config,
  lib,
  ...
}: {
  options.modules.hardware.bluetooth.enable = lib.mkOption {
    default = true;
    type = lib.types.bool;
    description = ''
      Add bluetooth support.
    '';
  };

  config = lib.mkIf config.modules.hardware.bluetooth.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    services.pipewire.wireplumber.extraConfig.bluetoothEnhancements = lib.mkIf config.modules.hardware.audio.enable {
      "monitor.bluez.properties" = {
        "bluez5.enable-sbc-xq" = true;
        "bluez5.enable-msbc" = true;
        "bluez5.enable-hw-volume" = true;
        "bluez5.roles" = ["hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag"];
      };
    };
  };
}
