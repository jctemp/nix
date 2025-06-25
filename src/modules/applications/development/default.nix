{
  lib,
  ctx,
  ...
}: {
  imports =
    lib.optionals (ctx.current == "system") [
      ./system.nix
    ]
    ++ lib.optionals (ctx.current == "home") [
      ./home.nix
    ];

  options.module.applications.development = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable development tools";
    };
  };
}
