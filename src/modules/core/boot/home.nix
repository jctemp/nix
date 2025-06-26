{
  config,
  lib,
  ctx,
  ...
}: let
  cfg = config.module.core.boot;
in {
  config = lib.mkIf cfg.enable {
    home.packages = 
      cfg.packages
      ++ lib.optionals ctx.gui cfg.packagesWithGUI;
  };
}