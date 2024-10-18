{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.nix-hardware.nixosModules.microsoft-surface-common
    ./hardware-configuration.nix
  ];

  module = {
    boot = {
      canTouchEfiVariables = true;
      loader = "systemd";
      device = "";
    };
    multimedia = {
      enable = true;
      bluetoothSupport = true;
    };
    rendering = {
      renderer = "gnome";
      nvidia = true;
      opengl = true;
    };

    privacy = {
      enable = true;
      supportYubikey = true;
    };
    virtualisation = {
      enable = true;
      kubernetes = null;
    };
    zfs = {
      enable = true;
      root = {
        enable = true;
        rollback = ["rpool/local/root@blank"];
      };
    };
  };

  # Nvidia Optimus
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "nvidia-offload" ''
      export __NV_PRIME_RENDER_OFFLOAD=1
      export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export __VK_LAYER_NV_optimus=NVIDIA_only
      exec -a "$0" "$@"
    '')
  ];

  hardware.nvidia.prime = {
    offload = {
      enable = true;
      enableOffloadCmd = true;
    };
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };
}
