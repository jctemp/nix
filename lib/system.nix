{...}: rec {
  # Get a consistent state version for all configurations
  getStateVersion = "24.11";

  # Get nixpkgs for a specific system with default overlays
  getPkgsForSystem = {
    system,
    nixpkgs,
    overlays ? [],
  }:
    import nixpkgs {
      inherit system overlays;
      config.allowUnfree = true;
    };

  # Generate a consistent stable hostId based on the hostname
  generateHostId = hostname:
    builtins.substring 0 8 (builtins.hashString "md5" hostname);

  # Check if the system is running in a virtual machine
  isVM = config: let
    virtualization = config.system.build.isVirtualMachine or false;
    hasCPUVirt = !config.boot.isContainer && config.hardware.cpu.intel.virtualisation.enable;
  in
    virtualization || hasCPUVirt;

  # Check if the system is running in WSL
  isWSL = config:
    config.wsl.enable or false;

  # Get appropriate kernel for the system type
  getKernel = config: pkgs:
    if isVM config
    then pkgs.linuxPackages
    else if config.hostSpec.kernelPackage or "" == "zen"
    then pkgs.linuxPackages_zen
    else if config.hostSpec.kernelPackage or "" == "hardened"
    then pkgs.linuxPackages_hardened
    else pkgs.linuxPackages;

  # Select packages based on system type
  selectPackagesBySystem = {
    server ? [],
    desktop ? [],
    vm ? [],
    wsl ? [],
  }: config:
    if isWSL config
    then wsl
    else if isVM config
    then vm
    else if config.modules.desktop.enable or false
    then desktop
    else server;
}
