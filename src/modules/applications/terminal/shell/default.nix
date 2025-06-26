{
  lib,
  ctx,
  ...
}: {
  imports =
    lib.optionals (ctx.current == "system") [./system.nix]
    ++ lib.optionals (ctx.current == "home") [./home.nix];

  options.module.applications.terminal.shell = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable shell configuration";
    };

    packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Additional shell packages";
    };

    packagesWithGUI = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Additional shell packages with GUI";
    };
  };
}