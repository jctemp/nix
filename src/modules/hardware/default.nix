{
  lib,
  ctx,
  ...
}: {
  imports = lib.optionals (ctx.current == "system") [
    ./bluetooth.nix
    ./facter.nix
    ./nvidia.nix
  ];

  hardware.enableRedistributableFirmware = true;
  services.fwupd.enable = true;
}
