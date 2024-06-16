{
  mergeHosts = configs:
    builtins.foldl' (hosts: host: hosts // host) {} configs;

  mkHost = args: {
    ${args.hostName} = args.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit (args) self hostId hostName userName zfsSupport cudaSupport;
        inherit (args.boot) device canTouchEfiVariables;
      };
      modules =
        [
          "${args.self}/machines/${args.hostName}"
          {
            nixpkgs.config.allowUnfree = true;
            system.stateVersion = args.stateVersion;
            users.users.${args.userName} = {
              hashedPassword = args.userPassword;
              isNormalUser = true;
              extraGroups = ["wheel"];
              openssh.authorizedKeys.keys = [args.userKey];
            };
          }
        ]
        ++ args.modules;
    };
  };
}
