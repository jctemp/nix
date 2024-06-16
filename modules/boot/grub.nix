{
  zfsSupport ? false,
  device ? "nodev",
  ...
}: {
  imports = [./base.nix];

  boot.loader.grub = {
    inherit device zfsSupport;
    enable = true;
    forceInstall = true;
    efiSupport = true;
    configurationLimit = 5;
  };
}
