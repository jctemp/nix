{
  description = "Uni Nix Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = inputs: let
    systems = ["x86_64-linux"];
    eachSystem = systems: func: inputs.nixpkgs.lib.genAttrs systems func;
    eachDefaultSystem = eachSystem systems;
  in {
    nixosConfigurations = let
      utils = import ./src/utils {inherit inputs;};
    in
      utils.mkMerge [
        (utils.mkSystem {
          name = "desktop";
          system = "x86_64-linux";
          stateVersion = "24.11";
          modules = [];
          gui = true;
        })
        # (utils.mkSystem {
        #   name = "laptop";
        #   system = "x86_64-linux";
        #   stateVersion = "24.11";
        #   modules = [
        #     inputs.nixos-hardware.nixosModules.microsoft-surface-common
        #     ({
        #       config,
        #       lib,
        #       ...
        #     }: {
        #       microsoft-surface.ipts.enable = true;
        #       config.microsoft-surface.surface-control.enable = true;
        #       users.users =
        #         lib.genAttrs
        #         (lib.attrNames config.users.users)
        #         (_name: {extraGroups = ["surface-control"];});
        #     })
        #   ];
        #   gui = true;
        # })
        # (utils.mkSystem {
        #   name = "cloud";
        #   system = "x86_64-linux";
        #   stateVersion = "25.05";
        #   modules = [];
        #   gui = false;
        # })
      ];

    homeConfigurations = let
      utils = import ./src/utils {inherit inputs;};
    in
      utils.mkMerge [
        (utils.mkHome {
          system = "x86_64-linux";
          name = "tmpl";
          stateVersion = "24.11";
          modules = [];
          gui = true;
        })
        # (utils.mkHome {
        #   system = "x86_64-linux";
        #   name = "remote";
        #   stateVersion = "24.11";
        #   modules = [];
        #   gui = false;
        # })
      ];

    formatter = eachDefaultSystem (system: inputs.nixpkgs.legacyPackages.${system}.alejandra);
    devShells = eachDefaultSystem (system: let
      pkgs = import inputs.nixpkgs {inherit system;};
    in {
      default =
        pkgs.mkShellNoCC
        {
          name = "nix-config";
          packages = [
            pkgs.alejandra
            pkgs.deadnix
            pkgs.statix
            pkgs.nix-melt
            pkgs.nix-diff
            pkgs.nix-tree
            pkgs.manix
          ];
          shellHook = ''
          '';
        };
    });
  };
}
