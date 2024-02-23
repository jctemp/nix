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

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    nixos-generators,
    nix-hardware,
  }: let
    mergeHosts = configs:
      builtins.foldl' (hosts: host: hosts // host) {} configs;
    mkHost = args: {
      ${args.hostName} = args.nixpkgs.lib.nixosSystem {
        specialArgs = {inherit (args) hostId hostName hostRole username;};
        modules =
          [
            "${args.self}/common"
            "${args.self}/roles"
            "${args.self}/machines/${args.hostName}"
            {
              nixpkgs.config.allowUnfree = true;
              system.stateVersion = args.stateVersion;
              users.users.${args.username} = {
                isNormalUser = true;
                extraGroups = ["wheel"];
              };
            }
          ]
          ++ args.modules;
      };
    };
    username = "temple";
  in
    {
      nixosConfigurations = mergeHosts [
        (mkHost {
          inherit self nixpkgs username;
          hostId = "eeae2b1c";
          hostName = "sussex";
          hostRole = "workstation";
          stateVersion = "23.11";
          modules = [];
        })
        (mkHost {
          inherit self nixpkgs username;
          hostId = "25365b33";
          hostName = "cornwall";
          hostRole = "workstation";
          stateVersion = "23.11";
          modules = [
            nix-hardware.nixosModules.microsoft-surface-common
          ];
        })
      ];
    }
    // (flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      formatter = pkgs.alejandra;
      packages = rec {
        default = iso;
        iso =
          if builtins.filter (x: x == system) ["x86_64-linux" "aarch64-linux"] != []
          then
            nixos-generators.nixosGenerate {
              inherit system;
              specialArgs = {inherit self pkgs;};
              modules = [./iso.nix];
              format = "install-iso";
            }
          else
            pkgs.stdenv.mkDerivation {
              name = "empty-derivation";
              inherit system;
            };
      };
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          (writeShellScriptBin "check" ''
            deadnix
            statix check
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
