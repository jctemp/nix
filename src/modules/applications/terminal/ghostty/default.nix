{
  lib,
  ctx,
  ...
}: {
  imports =
    lib.optionals (ctx.current == "system") [./system.nix]
    ++ lib.optionals (ctx.current == "home") [./home.nix];

  options.module.applications.terminal.ghostty = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Ghostty terminal emulator";
    };

    packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Additional Ghostty packages";
    };

    packagesWithGUI = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Additional Ghostty packages with GUI";
    };
  };
}