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
  # Create context for modules
  ctx = {
    current = "home";
    inherit gui;
  };

  pkgs = import inputs.nixpkgs-unstable {
    inherit system;
    config.allowUnfree = true;
  };
in {
  "${name}" = inputs.home-manager.lib.homeManagerConfiguration {
    inherit pkgs;

    extraSpecialArgs =
      {
        inherit inputs ctx;
      }
      // extraSpecialArgs;

    modules =
      [
        # Core home configuration
        {
          home = {
            username = name;
            homeDirectory = "/home/${name}";
            inherit stateVersion;
          };

          programs.home-manager.enable = true;
        }

        # Import main modules (absolute path from root)
        (root + "/modules")

        # User-specific settings
        (root + "/settings/users/${name}")
      ]
      ++ modules;
  };
}
