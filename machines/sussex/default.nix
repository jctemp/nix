{self, ...}: {
  imports = [
    ./hardware-configuration.nix

    "${self}/modules/base.nix"
    "${self}/modules/boot/systemd.nix"
    "${self}/modules/nvidia.nix"
    "${self}/modules/gnome.nix"
    "${self}/modules/media/all.nix"
    "${self}/modules/pgp.nix"
    "${self}/modules/virtualisation.nix"
    "${self}/modules/zfs.nix"
  ];
}
