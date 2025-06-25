{
  lib,
  ctx,
  ...
}: {
  imports =
    lib.optionals (ctx.current == "system") [
      ./system.nix
    ]
    ++ lib.optionals (ctx.current == "home") [
      ./home.nix
    ];

  options.module.core.users = {
    primaryUser = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Primary user for this host (if none first administrator is used)";
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
      description = "The collection of available users to systems";
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
}
