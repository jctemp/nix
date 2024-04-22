# Music, video, audio and other media
{
  config,
  lib,
  ...
}:
lib.mkIf config.hosts.desktop.enable {
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {General = {Enable = "Source,Sink,Media,Socket";};};
  };

  services.blueman.enable = true;
}
