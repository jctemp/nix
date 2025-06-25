{
  lib,
  ctx,
  ...
}: {
  imports =
    lib.optionals (ctx.current == "system") [./system.nix]
    ++ lib.optionals (ctx.current == "home") [./home.nix];

  options.module.applications.productivity = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable productivity applications";
    };

    packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Additional productivity packages";
    };

    packagesWithGUI = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Additional productivity packages with GUI";
    };
  };
}