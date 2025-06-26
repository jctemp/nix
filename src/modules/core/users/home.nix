{
  config,
  lib,
  ctx,
  ...
}: let
  cfg = config.module.core.users;
in {
  config = lib.mkIf cfg.enable {
    home.packages = 
      cfg.packages
      ++ lib.optionals ctx.gui cfg.packagesWithGUI;
  };
}