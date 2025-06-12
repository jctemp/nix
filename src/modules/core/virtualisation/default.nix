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

  options.module.core.virtualisation = {
    enable = {
      type = lib.types.bool;
      default = false;
      description = "Enable virtualisation services and applications";
    };

    containers = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable container virtualization";
      };

      backend = lib.mkOption {
        type = lib.types.enum ["podman" "docker"];
        default = "podman";
        description = "Container backend to use";
      };
    };
  };
}
