{zfsSupport ? false, ...}: {
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {General = {Enable = "Source,Sink,Media,Socket";};};
  };

  services.blueman.enable = true;

  systemd.tmpfiles.rules =
    if zfsSupport
    then [
      # https://www.freedesktop.org/software/systemd/man/latest/tmpfiles.d.html
      # create symlink to
      "L /var/lib/bluetooth - - - - /persist/var/lib/bluetooth"
    ]
    else [];
}
