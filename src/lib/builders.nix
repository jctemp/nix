{
  nixpkgs,
  home-manager ? null,
  ...
}: let
  inherit (nixpkgs) lib;
in {
  mkSystem = {
    name,
    system ? "x86_64-linux",
    stateVersion ? "24.11",
    modules ? [],
    gui ? false,
  }:
    assert lib.isString name;
    assert lib.isString system;
    assert lib.isString stateVersion;
    assert lib.isList modules; {
      "${name}" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = let
          ctx = {
            inherit gui;
            current = "system";
          };
          utils = import ./conditionals.nix {inherit lib ctx;};
        in {
          inherit ctx utils;
        };
        modules =
          [
            {
              system.stateVersion = stateVersion;
              networking.hostName = name;
              hostId = builtins.substring 0 8 (builtins.hashString "md5" name);
            }
          ]
          ++ modules;
      };
    };

  mkUser = {
    name,
    system ? "x86_64-linux",
    stateVersion ? "24.11",
    modules ? [],
    gui ? false,
  }:
    assert lib.isString name;
    assert lib.isString system;
    assert lib.isString stateVersion;
    assert lib.isList modules;
    assert home-manager != null; {
      "${name}" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {inherit system;};
        extraSpecialArgs = let
          ctx = {
            inherit gui;
            current = "home";
          };
          utils = import ./conditionals.nix {inherit lib ctx;};
        in {
          inherit ctx utils;
        };
        modules =
          [
            {
              home.stateVersion = stateVersion;
              home.username = name;
              home.homeDirectory = "/home/${name}";
            }
          ]
          ++ modules;
      };
    };
}
