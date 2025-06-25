{inputs, ...}: let
  inherit (inputs.nixpkgs) lib;

  # Get the root directory (src/)
  root = "${inputs.self}/src";

  # Import utility functions
  mkMerge = import ./merge.nix {inherit lib;};
  mkSystem = import ./system.nix {inherit inputs root;};
  mkHome = import ./home.nix {inherit inputs root;};
in {
  inherit mkMerge mkSystem mkHome;
}
