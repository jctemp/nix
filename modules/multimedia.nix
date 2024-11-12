{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.module.multimedia;
in {
  options.module.multimedia = {
    enable = lib.mkOption {
      default = true;
      defaultText = "true";
      description = "Whether to enable the module.";
      type = lib.types.bool;
    };
    bluetoothSupport = lib.mkOption {
      default = true;
      defaultText = "true";
      description = "Whether to enable Bluetooth support for the device.";
      type = lib.types.bool;
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      # PRINTING
      services = {
        avahi = {
          enable = true;
          nssmdns4 = true;
          openFirewall = true; # required for UDP 5353
          publish = {
            enable = true;
            userServices = true;
          };
        };

        printing = {
          enable = true;
          drivers = [
            pkgs.gutenprint
            pkgs.epson-escpr
            pkgs.epson-escpr2
          ];
          browsing = true;
          browsedConf = ''
            BrowseDNSSDSubTypes _cups,_print
            BrowseLocalProtocols all
            BrowseRemoteProtocols all
            CreateIPPPrinterQueues All
            BrowseProtocols all
          '';
        };
      };

      # AUDIO
      hardware.pulseaudio.enable = false;
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa = {
          enable = true;
          support32Bit = true;
        };
        pulse.enable = true;
        jack.enable = true;
      };
    })

    (lib.mkIf (cfg.enable && cfg.bluetoothSupport) {
      environment.etc = {
        "wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = ''
          bluez_monitor.properties = {
            ["bluez5.enable-sbc-xq"] = true,
            ["bluez5.enable-msbc"] = true,
            ["bluez5.enable-hw-volume"] = true,
            ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
          }
        '';
      };

      # BLUETOOTH
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
        settings = {General = {Enable = "Source,Sink,Media,Socket";};};
      };

      services.blueman.enable = true;
    })
  ];
}
