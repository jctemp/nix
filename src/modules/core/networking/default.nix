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

  options.module.core.networking = {
    enable = {
      type = lib.types.bool;
      default = false;
      description = "Enable networking services and applications";
    };
  };
}
