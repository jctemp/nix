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

  # Import host-specific settings if they exist
  hostSettingsPath = root + "/settings/hosts/${name}.nix";
  hostSettings =
    if builtins.pathExists hostSettingsPath
    then import hostSettingsPath
    else {};

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
        hostSettings

        # Third party modules
        inputs.disko.nixosModules.disko
        inputs.nixos-facter-modules.nixosModules.facter
        inputs.impermanence.nixosModules.impermanence
      ]
      ++ userModules
      ++ modules;
  };
}
