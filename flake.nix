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

    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    nix-hardware,
    nixos-generators,
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

    packages.${system} = let
      image = type:
        nixos-generators.nixosGenerate {
          inherit system;
          format = type;
          specialArgs = {
            inherit self;
          };
          modules = [
            ./iso.nix
          ];
        };
    in {
      installer = image "install-iso";
    };
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
          #nix-hardware.nixosModules.microsoft-surface-common
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

        alejandra
        deadnix
        nil
        statix
      ];
      shellHook = ''
        GREEN="\033[0;32m"
        NC="\033[0m"
        BOLD="\033[1m"

        echo -e "''${GREEN}NixOS Configuration''${NC}"
        echo -e ""
        echo -e "''${BOLD}check''${NC}"
        echo -e "  - Formats all nix files"
        echo -e "  - Checks the flake"
        echo -e ""
        echo -e "''${BOLD}update''${NC}"
        echo -e "  - Formats all nix files"
        echo -e "  - Updates the lock file"
        echo -e ""
        echo -e "''${BOLD}upgrade''${NC}"
        echo -e "  - Formats all nix files"
        echo -e "  - Updates the lock file"
        echo -e "  - Switches to the new configuration"
        echo -e ""
      '';
    };
  };
}
