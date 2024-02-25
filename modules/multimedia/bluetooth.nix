# Music, video, audio and other media
_: {
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {General = {Enable = "Source,Sink,Media,Socket";};};
  };

  services.blueman.enable = true;
}
