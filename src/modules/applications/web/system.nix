{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.module.applications.web;
in {
  options.module.applications.web = {
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Extra web packages to install system-wide";
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages =
      cfg.extraPackages
      ++ (with pkgs; [
        curl
        wget
        httpie # https://httpie.io/cli
      ]);
  };
}
