{
  lib,
  ctx,
  ...
}: {
  mkIfSystem = lib.mkIf (ctx.current == "system");
  mkIfUser = lib.mkIf (ctx.current == "user");
  mkIfHeadless = lib.mkIf (!ctx.gui);
}
