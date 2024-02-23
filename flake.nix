{
  description = "NixOS system configuration";

  nixConfig = {
    experimental-features = ["nix-command" "flakes"];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs = inputs @ {self, ...}: let
    lib = import ./lib.nix {inherit (inputs) nixpkgs;};
    user = "temple";
  in
    {
      nixosConfigurations = lib.mergeHosts [
        (lib.mkHost {
          inherit self;
          inherit user;
          hostId = "eeae2b1c";
          hostName = "sussex";
          hostRole = "workstation";
          stateVersion = "23.11";
          modules = [];
        })
        (lib.mkHost {
          inherit self;
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
    // (inputs.flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      formatter = pkgs.alejandra;
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
