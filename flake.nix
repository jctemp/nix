{
  description = "NixOS system configuration";

  nixConfig = {
    experimental-features = ["nix-command" "flakes"];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";

    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix-hardware,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    lib = import ./lib.nix {
      inherit self nixpkgs pkgs;
    };
    users = [
      {
        userName = "temple";
        hashedPassword = "$y$j9T$w/AhqxbUlgZ9BNIomxHAC0$qYJ1E.lfV7I6u4cDQ3Zprk5HKsMYgR1iWEgUAuWFnr4";
        isSudoer = true;
      }
    ];
  in {
    formatter.${system} = pkgs.alejandra;

    nixosConfigurations = {
      sussex = lib.mkHost {
        inherit system users;
        hostName = "sussex";
        version = "23.11";
      };
      cornwall = lib.mkHost {
        inherit system users;
        hostName = "cornwall";
        version = "23.11";
        modules = [
          # MS Surface patches
          nix-hardware.nixosModules.microsoft-surface-common
        ];
      };
    };

    # homeConfigurations = {
    #   ${user} = home-manager.lib.homeManagerConfiguration {
    #     inherit pkgs;
    #     extraSpecialArgs = {
    #       inherit inputs;
    #       username = "${user}";
    #     };
    #     modules = [
    #       {
    #         system.stateVersion = "23.11";
    #       }
    #     ];
    #   };
    # };

    devShells.${system}.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        (writeShellScriptBin "check" ''
          nix fmt --no-write-lock-file
          nix flake check --no-write-lock-file
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
          nix flake update --commit-lock-file
          sudo nixos-rebuild switch --flake .#"''${hostname}"
        '')

        deadnix
        nil
        alejandra
        statix
      ];
    };
  };
}
