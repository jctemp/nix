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

  options.module.applications.zellij = {
    enable = {
      type = lib.types.bool;
      default = false;
      description = "Enable zellij services and applications";
    };
  };
}
