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
        specialArgs = {inherit (args) hostId hostName hostRole userName userKey;};
        modules =
          [
            "${args.self}/modules"
            "${args.self}/machines/${args.hostName}"
            {
              nixpkgs.config.allowUnfree = true;
              system.stateVersion = args.stateVersion;
              users.users.${args.userName} = {
                isNormalUser = true;
                extraGroups = ["wheel"];
                openssh.authorizedKeys.keys = [args.userKey];
              };
            }
          ]
          ++ args.modules;
      };
    };
    userName = "temple";
    userKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDKzE8tMyXIM8Fq/9/ubwP9tlqL0WTlZ7NBF4pcO/p3T7AZD2W9W2c/tzbnk/GeqOKEF94VLO1dmHOAUW3WjbjgdtLhnVetSLTfYYUYYSPueX56FBHN8734kQRaYQ0jGMTA8TnH+dnZo6N1wdZZx/yIEyCQ4+N6EdNGxq9Y35joepubZL3LuaHWJj3BTswYorrDwRvkVaEFSS3CLGHWxOmey7dt7GAvKz2rod6uA4jZjbXzFSfMdyXq7/t1uclxHYPwd3imoMCtf67qn/qRs7S6v6vE3d5+XnMYMjDKAjv9uPw2O3DpdEgCfgUIkDYJ6u7aJ9DkLRpTNm2XVTKXqcWwVyKvR8SiprchJGge+mSC+GIooHvylzPxR+NyI/iZIcR2HO4kxHymTYoV4NEAr5LCT5Vew9QyIB9nyf5UJt4zYr9CJ8gCsK/oBeOBJeeAzZuH6/A4Zxt8gt6vtJ46eXk+gHFsF+YODtBMHrSR0TGODcWu3oz+Jmm+LtPbbbUR75kWjvnPr+H8jmgo3U/DGFHZij1XpGRapr7xMHRlah6lE7sIWk2Kb4zAMvw8yZqrMd0wA+UwpVYgGIZhjHP2SklwZig9hLjAQvXsWK2fbz6vvARWQ+6jRSMvYDEWf9LUP86gj+q+oKxkcQLad43ygzNK9RRBCYzSDNt8uB23DrXnkw== openpgp:0x63921A88";
  in
    {
      nixosConfigurations = mergeHosts [
        (mkHost {
          inherit self nixpkgs userName userKey;
          hostId = "eeae2b1c";
          hostName = "sussex";
          hostRole = "workstation";
          stateVersion = "23.11";
          modules = [];
        })
        (mkHost {
          inherit self nixpkgs userName userKey;
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
              format = "iso";
              # format = "install-iso";
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
