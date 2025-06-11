{
  lib,
  ctx,
  ...
}: {
  optionalsGUI = lib.optionals (ctx.gui);
  optionalsHeadless = lib.optionals (!ctx.gui);

  mkIfSystem = lib.mkIf (ctx.current == "system");
  mkIfUser = lib.mkIf (ctx.current == "home");

  mkIfSystemOr = cond: lib.mkIf ((ctx.current == "system") || cond);
  mkIfUserOr = cond: lib.mkIf ((ctx.current == "home") || cond);

  mkIfSystemAnd = cond: lib.mkIf ((ctx.current == "system") && cond);
  mkIfUserAnd = cond: lib.mkIf ((ctx.current == "home") && cond);
}
