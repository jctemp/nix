{
  description = "NixOS system configuration";

  nixConfig = {
    experimental-features = ["nix-command" "flakes"];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
    nix-hardware.url = "github:NixOS/nixos-hardware";
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: let
    users = import "${inputs.self}/users.nix";
    lib = import "${inputs.self}/lib.nix" inputs.nixpkgs;
    ulib = lib.users;
  in
    {
      nixosConfigurations = lib.hosts.merge [
        (lib.hosts.create {
          inherit inputs ulib;
          users = users.personal;
          system = "x86_64-linux";
          hostName = "sussex";
          stateVersion = "23.11";
          device = "/dev/nvme0n1";
        })
        (lib.hosts.create {
          inherit inputs ulib;
          users = users.personal;
          system = "x86_64-linux";
          hostName = "cornwall";
          stateVersion = "23.11";
          device = "/dev/nvme0n1";
        })
        (lib.hosts.create {
          inherit inputs ulib;
          users = users.server;
          system = "x86_64-linux";
          hostName = "kent";
          stateVersion = "23.11";
          device = "/dev/sda";
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
      devShells.default = pkgs.mkShellNoCC {
        packages = (import "${inputs.self}/scripts.nix" pkgs) ++ [pkgs.jq];
        shellHook = "overview";
      };
    }));
}
