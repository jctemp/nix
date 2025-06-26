{
  inputs,
  root,
}: {
  name,
  system,
  stateVersion,
  modules ? [],
  gui ? true,
  extraSpecialArgs ? {},
}: let
  lib = inputs.nixpkgs.lib;

  userModules = let
    paths = builtins.readDir (root + "/settings/users");
    users = lib.mapAttrsToList (name: type:
      if type == "directory"
      then name
      else null)
    paths;
  in
    lib.map (user: root + "/settings/users/${user}") users;

  # Create context for modules
  ctx = {
    current = "system";
    inherit gui;
  };
in {
  "${name}" = inputs.nixpkgs.lib.nixosSystem {
    inherit system;

    specialArgs =
      {
        inherit ctx inputs;
        inherit (inputs) self nixpkgs;
      }
      // extraSpecialArgs;

    modules =
      [
        # Core system configurations
        {
          system.stateVersion = stateVersion;
          networking.hostName = name;
          networking.hostId = builtins.substring 0 8 (builtins.hashString "md5" name);
        }

        # Import main modules (absolute path from root)
        (root + "/modules")

        # Host-specific settings
        (root + "/settings/hosts/${name}.nix")

        # Third party modules
        inputs.disko.nixosModules.disko
        inputs.nixos-facter-modules.nixosModules.facter
        inputs.impermanence.nixosModules.impermanence
      ]
      ++ userModules
      ++ modules;
  };
}
