{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.host.printing;
in {
  imports = [];

  options.host.printing = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable printing support.";
    };
    drivers = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [pkgs.gutenprint];
      description = "List of packages to install for printing support.";
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      # This is the recommended way to support printing on NixOS. Modern
      # printers should work out of the box.
      avahi = {
        enable = true;
        nssmdns = true;
        openFirewall = true;
      };
      # Alternative to avahi is to use CUPS.
      printing = {
        enable = false;
        drivers = [pkgs.gutenprint];
      };
    };
  };

  # https://nixos.wiki/wiki/Printing
}
