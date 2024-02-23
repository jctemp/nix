{
  lib,
  hostRole,
  ...
}: let
  hostRoles = ["workstation" "server"];

  modulePath =
    if
      lib.assertOneOf "hostRole is not valid" hostRole hostRoles
      && hostRole == "workstation"
    then ./workstation
    else ./server;
in {
  imports = [modulePath];
}
