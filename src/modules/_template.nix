{
  config,
  lib,
  utils,
  ...
}: let
  cfg = config.modules.NAMESPACE.MODULE;
in {
  # UTILS
  # mkIfSystem = lib.mkIf (ctx.current == "system");
  # mkIfUser = lib.mkIf (ctx.current == "home");
  # mkIfHeadless = lib.mkIf (!ctx.gui);
  # mkIfSystemOr = cond: lib.mkIf ((ctx.current == "system") || cond);
  # mkIfUserOr = cond: lib.mkIf ((ctx.current == "home") || cond);
  # mkIfHeadlessOr = cond: lib.mkIf ((!ctx.gui) || cond);
  # mkIfSystemAnd = cond: lib.mkIf ((ctx.current == "system") && cond);
  # mkIfUserAnd = cond: lib.mkIf ((ctx.current == "home") && cond);
  # mkIfHeadlessAnd = cond: lib.mkIf ((!ctx.gui) && cond);
  options.modules.NAMESPACE.MODULE = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable MODULE module";
    };
  };

  config = lib.mkMerge [
    (utils.mkIfSystemAnd (cfg.enable) {
      })
    (utils.mkIfHomeAnd (cfg.enable) {
      })
  ];
}
