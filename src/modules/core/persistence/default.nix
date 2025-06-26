# TODO: rework the persistence definition for the current configurations structure
# at the moment I am assuming that all my hosts want the same partition schema
# Accordingly, I like to build a system that allows me define on a high-level the
# size of sections and make sections like the swap optional. Further, I want to
# enable the support for multi-disk partition schemas like mirrors and/or raid10.
# Finally, I think the concept of zvols should be explored for data pools???
# Idea is to make the configuration fit for user and server use.
{
  lib,
  ctx,
  ...
}: {
  imports =
    lib.optionals (ctx.current == "system") [./system.nix]
    ++ lib.optionals (ctx.current == "home") [./home.nix];

  options.module.core.persistence = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable persistence services and applications";
    };

    packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Additional persistence packages";
    };

    packagesWithGUI = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Additional persistence packages with GUI";
    };
  };
}