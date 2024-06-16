{...}: {
  imports = [./base.nix];

  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 5;
  };
}
