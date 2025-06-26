{
  lib,
  ctx,
  ...
}: {
  imports =
    lib.optionals (ctx.current == "system") [./system.nix]
    ++ lib.optionals (ctx.current == "home") [./home.nix];

  options.module.core.gnome = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable GNOME desktop environment";
    };

    packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Additional GNOME packages";
    };

    packagesWithGUI = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Additional GNOME packages with GUI";
    };
  };
}