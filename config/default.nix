inputs: let
  mkHost = hostName: system:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {inherit inputs;};
      modules = [
        "${inputs.self}/config/modules"
        "${inputs.self}/config/hosts"
        "${inputs.self}/config/hosts/${system}.${hostName}"
        "${inputs.self}/config/disko.nix"
        "${inputs.self}/config/user.nix"
        (
          {...}: {
            hostSpec = { inherit hostName system; };
            system.stateVersion = "24.11";
          }
        )
      ];
    };
  mkHosts = hosts: builtins.foldl' (configs: host: configs // {${host.name} = mkHost host.name host.system;}) {} hosts;
  readHosts = path: let
    lib = inputs.nixpkgs.lib;
    readed = builtins.readDir path;
    filtered = builtins.filter (name: readed.${name} == "directory") (builtins.attrNames readed);
    mapped = builtins.map (name: lib.strings.splitString "." name) filtered;
    result =
      builtins.map (tuple: {
        system = builtins.head tuple;
        name = lib.last tuple;
      })
      mapped;
  in
    result;
in
  mkHosts (readHosts "${inputs.self}/config/hosts")
