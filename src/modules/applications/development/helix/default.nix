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

  options.module.applications.development.helix = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable helix text editor";
    };
  };
}
