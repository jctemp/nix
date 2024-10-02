{
  self,
  pkgs,
  lib,
  userName,
  hostName,
  ...
}: {
  imports = [
    "${self}/modules/base.nix"
    "${self}/modules/pgp.nix"
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld-rs;
  };

  wsl = {
    enable = true;
    defaultUser = userName;
    docker-desktop.enable = true;
    interop = {
      includePath = true;
      register = true;
    };
    nativeSystemd = true;
    useWindowsDriver = true;
    wslConf.network.hostname = hostName;
  };
}
