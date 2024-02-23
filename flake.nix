{
  description = "NixOS system configuration";

  nixConfig = {
    experimental-features = ["nix-command" "flakes"];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs = inputs @ {flake-utils, ...}: let
    lib = import ./lib.nix {inherit (inputs) nixpkgs home-manager;};
    user = "temple";
  in
    {
      nixosConfigurations = lib.mergeHosts [
        (lib.mkHost {
          inherit (inputs) self;
          inherit user;
          hostId = "eeae2b1c";
          hostName = "sussex";
          hostRole = "workstation";
          stateVersion = "23.11";
          modules = [];
        })
        (lib.mkHost {
          inherit (inputs) self;
          inherit user;
          hostId = "25365b33";
          hostName = "cornwall";
          hostRole = "workstation";
          stateVersion = "23.11";
          modules = [
            inputs.nix-hardware.nixosModules.microsoft-surface-common
          ];
        })
      ];
    }
    // (flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      formatter = pkgs.alejandra;
      homeConfigurations = {
        ${user} = lib.mkHome {
          inherit (inputs) self;
          inherit pkgs user;
          stateVersion = "23.11";
        };
      };
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          (writeShellScriptBin "check" ''
            nix fmt --no-write-lock-file
            nix flake check --no-write-lock-file --all-systems
          '')
          (writeShellScriptBin "update" ''
            nix fmt --no-write-lock-file
            nix flake update --commit-lock-file
          '')
          (writeShellScriptBin "upgrade" ''
            if [ -z "$1" ]; then
              hostname=$(hostname)
            else
              hostname=$1
            fi
            nix fmt --no-write-lock-file
            sudo nixos-rebuild switch --flake .#"''${hostname}"
          '')
          alejandra
          deadnix
          nil
          statix
        ];
      };
    }));
}
