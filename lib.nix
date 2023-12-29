{
  self,
  nixpkgs ? <nixpkgs>,
  ...
}: rec {
  mkUsers = users:
    builtins.foldl'
    (all: user: all // user) {} (builtins.map mkUser users);

  mkUser = {
    # Name of the user, e.g. "nixos"
    userName,
    # Password hash, use mkpasswd
    hashedPassword,
    # Sudoer?
    isSudoer ? false,
  }: {
    ${userName} = {
      inherit hashedPassword;
      isNormalUser = true;
      extraGroups =
        if isSudoer
        then ["wheel" "networkmanager"]
        else ["networkmanager"];
    };
  };

  # Create a NixOS systems derivation.
  mkHost = {
    # Name of the host, e.g. "nixos"
    hostName,
    # The state version to use, e.g. "23.05"
    version,
    # System users, e.g. [ { userName = "nixos"; hashedPassword = "..."; isSudoer = true; }; ]
    users ? [],
    # The architecture, e.g. "x86_64-linux"
    system ? "x86_64-linux",
    # Modules to import, e.g. [ ./modules/foo.nix ]
    modules ? [],
  }: let
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in
    nixpkgs.lib.nixosSystem
    {
      inherit system;
      specialArgs = {inherit self pkgs hostName version users;};
      modules =
        [
          "${self}/nixos"
          "${self}/nixos/host/${hostName}"
          {users.users = mkUsers users;}
        ]
        ++ modules;
    };
}
