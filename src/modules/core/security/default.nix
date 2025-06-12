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

  options.module.core.security = {
    enable = {
      type = lib.types.bool;
      default = false;
      description = "Enable security services and applications";
    };
  };
}
