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

  options.module.applications.git = {
    enable = {
      type = lib.types.bool;
      default = false;
      description = "Enable git services and applications";
    };
  };
}
