{
  lib,
  ctx,
  ...
}: {
  imports =
    lib.optionals (ctx.current == "system") [./system.nix]
    ++ lib.optionals (ctx.current == "home") [./home.nix];

  options.module.core.networking = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable networking services and applications";
    };

    packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Additional networking packages";
    };

    packagesWithGUI = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Additional networking packages with GUI";
    };
  };
}