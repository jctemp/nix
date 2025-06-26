{
  lib,
  ctx,
  ...
}: {
  imports =
    lib.optionals (ctx.current == "system") [./system.nix]
    ++ lib.optionals (ctx.current == "home") [./home.nix];

  options.module.core.audio = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable audio services and applications";
    };

    packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Additional audio packages";
    };

    packagesWithGUI = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Additional audio packages with GUI";
    };

    backend = lib.mkOption {
      type = lib.types.enum ["pipewire" "pulseaudio"];
      default = "pipewire";
      description = "Audio backend to use";
    };
  };
}