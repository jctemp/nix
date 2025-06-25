{ctx, ...}:
if ctx.current != "system"
then {}
else {
  imports = [
    ./bluetooth.nix
    ./facter.nix
    ./nvidia.nix
  ];

  config = {
    hardware.enableRedistributableFirmware = true;
    services.fwupd.enable = true;
  };
}
