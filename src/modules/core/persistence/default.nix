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

  options.module.core.persistence = {
    enable = {
      type = lib.types.bool;
      default = false;
      description = "Enable persistence services and applications";
    };

    # TODO: Add more shared options
  };
}
