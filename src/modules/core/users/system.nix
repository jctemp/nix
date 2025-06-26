{
  config,
  lib,
  ctx,
  ...
}: let
  cfg = config.module.core.users;
in {
  options.module.core.users = {
    primaryUser = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Primary user for this host. If none, first admin is default.";
    };

    users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "List of users to enable on this host";
    };

    administrators = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "List of users to add to the wheel group";
    };

    collection = lib.mkOption {
      description = "The collection of available users. Will be automatically populated";
      default = {};
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          hashedPassword = lib.mkOption {
            type = lib.types.str;
            description = "Hashed password";
          };
          keys = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
            description = "SSH public keys";
          };
        };
      });
    };
  };

  config = lib.mkIf cfg.enable (let
    checkGroups = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
  in {
    environment.systemPackages = 
      cfg.packages
      ++ lib.optionals ctx.gui cfg.packagesWithGUI;

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
            The user '${name}' is not defined in user collection.
            Please add a definition for the user.
          ''
          name;
      in {
        hashedPassword = cfg.collection.${user}.hashedPassword;
        openssh.authorizedKeys.keys = cfg.collection.${user}.keys;
        isNormalUser = true;
        extraGroups =
          (lib.optionals (lib.any (u: u == user) cfg.administrators) [
            "wheel"
          ])
          ++ (checkGroups [
            "audio"
            "video"
            "docker"
            "podman"
            "libvirt"
            "git"
            "networkmanager"
            "scanner"
            "lp"
            "kvm"
            "surface-control"
          ]);
      }
    );

    security.sudo.extraConfig = ''
      Defaults        timestamp_timeout=15
    '';
    security.sudo.wheelNeedsPassword = true;
  });
}