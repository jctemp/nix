{
  pkgs,
  lib,
  ctx,
  ...
}: {
  imports =
    [
      ./audio
      ./boot
      ./gnome
      ./locale
      ./networking
      ./persistence
      ./printing
      ./security
      ./users
      ./virtualisation
    ]
    ++ (lib.optionals (ctx.current == "system") [./system.nix]);
}
