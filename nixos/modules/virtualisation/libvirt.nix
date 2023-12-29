{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.host.libvirt;
in {
  imports = [];

  options.host.libvirt = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable libvirt daemon";
    };
    users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Users allowed to use libvirt";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true; # since 23.11

    environment.systemPackages = [
      pkgs.libguestfs
    ];

    users.users = builtins.foldl' (result: set: result // set) {} (
      builtins.map
      (user: {${user} = {extraGroups = ["libvirt"];};})
      cfg.users
    );
  };
}
