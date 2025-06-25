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

  options.module.applications.web = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable web services and applications";
    };
  };
}
