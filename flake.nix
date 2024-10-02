{
  description = "NixOS system configuration";

  nixConfig = {
    experimental-features = ["nix-command" "flakes"];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
    nix-hardware.url = "github:NixOS/nixos-hardware";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    nix-hardware,
    nixos-wsl,
  }: let
    lib = import ./lib/utils.nix;

    userName = "temple";
    userPassword = "$y$j9T$C3qwfGNOj6WptYGkV9.jJ1$JkNh2o8AgBUzYt7n/HT8p/CMcJUn2OP0GkzmpdITuk2";
    userKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDKzE8tMyXIM8Fq/9/ubwP9tlqL0WTlZ7NBF4pcO/p3T7AZD2W9W2c/tzbnk/GeqOKEF94VLO1dmHOAUW3WjbjgdtLhnVetSLTfYYUYYSPueX56FBHN8734kQRaYQ0jGMTA8TnH+dnZo6N1wdZZx/yIEyCQ4+N6EdNGxq9Y35joepubZL3LuaHWJj3BTswYorrDwRvkVaEFSS3CLGHWxOmey7dt7GAvKz2rod6uA4jZjbXzFSfMdyXq7/t1uclxHYPwd3imoMCtf67qn/qRs7S6v6vE3d5+XnMYMjDKAjv9uPw2O3DpdEgCfgUIkDYJ6u7aJ9DkLRpTNm2XVTKXqcWwVyKvR8SiprchJGge+mSC+GIooHvylzPxR+NyI/iZIcR2HO4kxHymTYoV4NEAr5LCT5Vew9QyIB9nyf5UJt4zYr9CJ8gCsK/oBeOBJeeAzZuH6/A4Zxt8gt6vtJ46eXk+gHFsF+YODtBMHrSR0TGODcWu3oz+Jmm+LtPbbbUR75kWjvnPr+H8jmgo3U/DGFHZij1XpGRapr7xMHRlah6lE7sIWk2Kb4zAMvw8yZqrMd0wA+UwpVYgGIZhjHP2SklwZig9hLjAQvXsWK2fbz6vvARWQ+6jRSMvYDEWf9LUP86gj+q+oKxkcQLad43ygzNK9RRBCYzSDNt8uB23DrXnkw== openpgp:0x63921A88";
  in
    {
      nixosConfigurations = lib.mergeHosts [
        (lib.mkHost {
          inherit self nixpkgs userName userPassword userKey;
          hostName = "sussex";
          cudaSupport = true;
          zfsSupport = true;
          yubikeySupport = true;
          boot = {
            device = "";
            canTouchEfiVariables = true;
          };
          stateVersion = "23.11";
          modules = [];
        })
        (lib.mkHost {
          inherit self nixpkgs userName userPassword userKey;
          hostName = "cornwall";
          cudaSupport = true;
          zfsSupport = true;
          yubikeySupport = true;
          boot = {
            device = "";
            canTouchEfiVariables = true;
          };
          stateVersion = "23.11";
          modules = [
            #nix-hardware.nixosModules.microsoft-surface-common
          ];
        })
        (lib.mkHost {
          inherit self nixpkgs userName userPassword userKey;
          hostName = "kent";
          cudaSupport = false;
          zfsSupport = true;
          yubikeySupport = false;
          boot = {
            device = "/dev/sda";
            canTouchEfiVariables = false;
          };
          stateVersion = "23.11";
          modules = [];
        })
        (lib.mkHost {
          inherit self nixpkgs userName userPassword userKey;
          hostName = "wsl";
          cudaSupport = false;
          zfsSupport = false;
          yubikeySupport = false;
          boot = null;
          stateVersion = "23.11";
          modules = [
            nixos-wsl.nixosModules.default
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
      devShells.default = pkgs.mkShell {
        packages = with pkgs;
          [
            alejandra
            deadnix
            nil
            statix
          ]
          ++ (import ./lib/devshell.nix {inherit pkgs;});
      };
    }));
}
