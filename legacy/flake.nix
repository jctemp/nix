{
  description = "NixOS system configuration";

  nixConfig = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
  inputs = {
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    flake-utils.url = "github:numtide/flake-utils";
    nix-hardware.url = "github:NixOS/nixos-hardware";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs = inputs:
    {
      nixosConfigurations = import ./config inputs;
    }
    // (inputs.flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in {
        formatter = pkgs.alejandra;
        devShells.default = pkgs.mkShellNoCC {
          name = "system config";
          packages = let
            scriptsPkgs = pkgs.callPackage ./scripts {};
          in [
            scriptsPkgs
            pkgs.nix
            pkgs.git
            (pkgs.vscode-with-extensions.override {
              vscodeExtensions = [
                pkgs.vscode-extensions.bbenoist.nix
                pkgs.vscode-extensions.kamadorueda.alejandra
                pkgs.vscode-extensions.jeff-hykin.better-nix-syntax
              ];
            })
          ];
        };
      }
    ));
}
