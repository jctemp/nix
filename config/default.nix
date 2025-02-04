inputs:
let
  mkHost =
    hostName:
    inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        "${inputs.self}/config/host-specs.nix"
        "${inputs.self}/config/hosts/${hostName}"
        "${inputs.self}/config/modules.nix"
        "${inputs.self}/config/disko.nix"
        "${inputs.self}/config/users.nix"
        (
          {  ... }:
          {
            # Set hostName for hostSpecs
            hostSpec.hostName = hostName;

            # Define state version
            system.stateVersion = "24.11";

            # Options for VM testing
            virtualisation.vmVariantWithBootLoader = {
              diskSize = 32768;
              memorySize = 8192;
              cores = 2;
            };
            virtualisation.vmVariant = {
              diskSize = 32768;
              memorySize = 8192;
              cores = 2;
            };
          }
        )
      ];
    };
  mkHosts =
    hosts: builtins.foldl' (configs: hostName: configs // { ${hostName} = mkHost hostName; }) { } hosts;
  readHosts = path: builtins.attrNames (builtins.readDir path);
in
mkHosts (readHosts "${inputs.self}/config/hosts")
