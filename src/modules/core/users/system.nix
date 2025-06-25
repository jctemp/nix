{
  config,
  lib,
  ...
}: let
  cfg = config.module.core.users;
in {
  options.module.core.users = {
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Extra packages to install system-wide";
    };
  };

  config = let
    checkGroups = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
  in {
    environment.systemPackages = cfg.extraPackages;
    systemd.tmpfiles.rules = lib.foldl (acc: elem: let
      u = config.users.users.${elem}.name;
      g = config.users.users.${elem}.group;
    in
      acc
      ++ [
        "d /home/${elem}/.ssh 0750 ${u} ${g} -"
        "d /home/${elem}/.ssh/sockets 0750 ${u} ${g} -"
      ]) [] (cfg.users ++ cfg.administrators);

    users.users = lib.genAttrs (cfg.administrators ++ cfg.users) (
      name: let
        user =
          lib.throwIfNot (lib.hasAttr name cfg.collection) ''
            The user '${name}' is not defined in $root/src/settings/users.
            Please add a definiton for the user you have specified in the
            host configuration or check for corresponding typos.
          ''
          name;
      in {
        hashedPassword = cfg.collection.${user}.hashedPassword;
        openssh.authorizedKeys.keys = cfg.collection.${user}.keys;
        isNormalUser = true;
        extraGroups =
          (lib.optionals (lib.any (u: u == user) cfg.administrators) [
            "wheel" # Enable sudo
          ])
          ++ (checkGroups [
            # Hardware access groups
            "audio"
            "video"

            # Virtualization groups
            "docker"
            "podman"
            "libvirt"

            # Special purpose groups
            "git"
            "networkmanager"

            # Printing and scanning
            "scanner"
            "lp"
          ]);
      }
    );

    security.sudo.extraConfig = ''
      Defaults        timestamp_timeout=15
    '';
    security.sudo.wheelNeedsPassword = true;
  };
}
