{
  nixpkgs,
  home-manager ? null,
  ...
}:
{
  mkMerge = listOfAttrs: builtins.foldl' (acc: elem: acc // elem) {} listOfAttrs;
}
// (import ./builders.nix {inherit nixpkgs home-manager;})
