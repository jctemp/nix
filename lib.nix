nixpkgs: rec {
  hosts = {
    merge =
      configs:
      builtins.listToAttrs (
        map (config: {
          name = config.hostName;
          value = config.nixosSystem;
        }) configs
      );
    create = args: {
      inherit (args) hostName;
      nixosSystem = nixpkgs.lib.nixosSystem {
        inherit (args) system;
        specialArgs = args;
        modules = [
          args.inputs.disko.nixosModules.disko

          "${args.inputs.self}/modules"
          "${args.inputs.self}/machines/${args.hostName}"
          "${args.inputs.self}/disko-config.nix"

          (
            { config, ... }:
            {
              users.users = users.createUsers args.users;
              nixpkgs.config.allowUnfree = config.module.rendering.nvidia;
              system.stateVersion = args.stateVersion;
              virtualisation.vmVariantWithBootLoader = {
                diskSize = 20480;
                memorySize = 8192;
                cores = 2;
              };
              virtualisation.vmVariant = {
                diskSize = 20480;
                memorySize = 8192;
                cores = 2;
              };
            }
          )
        ];
      };
    };
  };
  users = rec {
    createUsers =
      configs:
      builtins.listToAttrs (
        map (config: {
          inherit (config) name;
          value = {
            hashedPassword = config.password;
            isNormalUser = true;
            extraGroups = if config.root then [ "wheel" ] else [ ];
            openssh.authorizedKeys.keys = [ config.ssh ];
          };
        }) configs
      );
    getNames =
      configs: pred:
      builtins.foldl' (names: user: names ++ (if pred user then [ user.name ] else [ ])) [ ] configs;
    populate =
      configs: subset: value:
      builtins.foldl' (set: user: set // { "${user}"."${subset}" = value; }) { } (
        getNames configs (u: u.root)
      );
  };
}
