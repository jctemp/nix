{
  description = "Default flake";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = inputs: let
    systems = ["x86_64-linux"];
    eachSystem = systems: func: inputs.nixpkgs.lib.genAttrs systems (system: func system);
    eachDefaultSystem = eachSystem systems;
  in {
    nixosConfigurations = {
      # TODO: add hosts
    };
    formatter = eachDefaultSystem (system: inputs.nixpkgs.legacyPackages.${system}.alejandra);
    devShells = eachDefaultSystem (system: let
      pkgs = import inputs.nixpkgs {inherit system;};
    in {
      default =
        pkgs.mkShellNoCC
        {
          name = "nix-config";
          packages = [
          ];
          shellHook = ''
          '';
        };
    });
  };
}
