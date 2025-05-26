{
  description = "NixOS system configuration";

  nixConfig = {
    experimental-features = ["nix-command" "flakes"];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOs/nixpkgs/nixos-unstable";

    # System configuration dependencies
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    nix-hardware.url = "github:NixOS/nixos-hardware";
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";

    # Home configuration dependencies
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    blender-bin.url = "github:edolstra/nix-warez?dir=blender";
  };

  outputs = inputs: let
    # Helper function to create a NixOS system
    mkSystem = hostName: userName: system: extraModules:
      inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs userName;};
        modules =
          [
            ./system/modules
            ./system/hosts/${hostName}

            # Common configurations
            ./system/modules/disk-config.nix
            ./system/modules/user-config.nix

            # System state version
            ({...}: {
              modules.hostSpec.hostName = hostName;
              system.stateVersion = "24.11";
            })
          ]
          ++ extraModules;
      };

    mkHome = userName: system: extraModules:
      inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = import inputs.nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
          overlays = [inputs.blender-bin.overlays.default];
        };
        extraSpecialArgs = {
          inherit inputs;
        };
        modules =
          [
            ./home/users/${userName}.nix
          ]
          ++ extraModules;
      };

    # Generate various system versions
    mkEach = systems: func:
      inputs.nixpkgs.lib.genAttrs systems (system: func system);
    mkEachDefault = mkEach ["x86_64-linux"];
  in {
    nixosConfigurations = {
      desktop = mkSystem "desktop" "tmpl" "x86_64-linux" [];
      laptop = mkSystem "laptop" "tmpl" "x86_64-linux" [
        inputs.nix-hardware.nixosModules.microsoft-surface-common
      ];
      vm = mkSystem "vm" "tmpl-cli" "x86_64-linux" [];
    };

    homeConfigurations = {
      "tmpl" = mkHome "tmpl" "x86_64-linux" [];
      "tmpl-cli" = mkHome "tmpl-cli" "x86_64-linux" [];
    };

    # Development utilities
    devShells = mkEachDefault (system: {
      default = let
        pkgs = import inputs.nixpkgs {inherit system;};
      in
        pkgs.mkShellNoCC {
          name = "system-config";
          packages = [
            pkgs.nix
            pkgs.git
            pkgs.alejandra
          ];
        };
    });

    formatter = mkEachDefault (system: inputs.nixpkgs.legacyPackages.${system}.alejandra);
  };
}
