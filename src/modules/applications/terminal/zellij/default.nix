{
  lib,
  ctx,
  ...
}: {
  imports =
    lib.optionals (ctx.current == "system") [./system.nix]
    ++ lib.optionals (ctx.current == "home") [./home.nix];

  options.module.applications.terminal.zellij = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable zellij terminal multiplexer";
    };

    packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Additional zellij packages";
    };

    packagesWithGUI = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Additional zellij packages with GUI";
    };
  };
}