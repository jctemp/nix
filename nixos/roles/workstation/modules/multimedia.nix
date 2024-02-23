# Music, video, audio and other media
{
  pkgs,
  username,
  ...
}: {
  environment = {
    systemPackages = with pkgs; [
      firefox
      audacity
      ffmpeg
      gimp
      nomacs
      vlc
    ];
  };

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {General = {Enable = "Source,Sink,Media,Socket";};};
    };
    pulseaudio = {
      enable = true;
      support32Bit = true;
      package = pkgs.pulseaudioFull;
    };
  };

  services = {
    blueman.enable = true;
    printing = {
      enable = true;
      drivers = [pkgs.gutenprint];
    };
  };

  users.users.${username}.extraGroups = ["audio"];
}
