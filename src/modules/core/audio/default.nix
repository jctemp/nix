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

  options.module.core.audio = {
    enable = {
      type = lib.types.bool;
      default = false;
      description = "Enable audio services and applications";
    };

    backend = lib.mkOption {
      type = lib.types.enum ["pipewire" "pulseaudio"];
      default = "pipewire";
      description = "Audio backend to use";
    };
  };
}
