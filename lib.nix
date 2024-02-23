/*
Flake NixOS configuration helper functions
*/
{
  nixpkgs ? import <nixpkgs> {},
  home-manager ? import <home-manager> {},
}: {
  /*
    *
  Merge a list of host configurations into a single attribute set.

  # Example

  ```nix
  mergeHosts [
    { hostA = { ... }; }
    { hostB = { ... }; }
  ]
  ```

  # Type

  ```
  mergeHosts :: [AttrSet] -> AttrSet
  ```

  # Arguments

  - [configs] A list of host configurations.

  */
  mergeHosts = configs:
    builtins.foldl' (hosts: host: hosts // host) {} configs;

  /*
    *
  Create a NixOS configuration for a single host.

  # Example

  ```nix
  mkHost {
    hostId = "eeffbbff";
    hostName = "hostA";
    stateVersion = "23.11";
    user = "username";
  }
  ```

  # Type

  ```
  mkHost :: AttrSet -> AttrSet
  ```

  # Arguments

  - [self] The current flake.
  - [hostId] The 32-bit host ID of the machine. Use `head -c4 /dev/urandom | od -A none -t x4`.
  - [hostName] The name of the machine. It must match the path: `./machines/<hostName>`.
  - [hostRole] The role of the machine. See `./roles` for available roles.
  - [stateVersion] The first version of NixOS one has installed on this particular machine.
  - [user] The users that should be created on this machine.
  - [modules] Arbitrary modules that are extern but must be available for this host.

  */
  mkHost = {
    self,
    hostId,
    hostName,
    hostRole,
    stateVersion,
    user,
    modules ? [],
  }: {
    ${hostName} = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit hostId hostName hostRole user;};
      modules = [
        "${self}/nixos/common"
        "${self}/nixos/roles"
        "${self}/nixos/machines/${hostName}"
        {
          nixpkgs.config.allowUnfree = true;
          system.stateVersion = stateVersion;
          users.users.${user} = {
            isNormalUser = true;
            extraGroups = ["wheel"];
          };
        }
      ];
    };
  };

  /*
    *
  Create a home-manager configuration for a user.

  # Example

  ```nix
  mkHome {
    temple = lib.mkHome {
      inherit (inputs) self;
      inherit user;
      stateVersion = "23.11";
    };
  }
  ```

  # Type

  ```
  mkHome :: AttrSet -> AttrSet
  ```

  # Arguments

  - [self] The current flake.
  - [pkgs] The Nixpkgs package set with a specific version and architecture.
  - [user] The user for which to create the home-manager configuration.
  - [stateVersion] The first version of NixOS one has installed on this particular machine.

  */
  mkHome = {
    self,
    pkgs,
    user,
    stateVersion,
  }: {
    ${user} = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      specialArgs = {
        inherit stateVersion;
        username = user;
      };
      modules = ["${self}/home/${user}"];
    };
  };
}
