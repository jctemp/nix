{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.nix-hardware.nixosModules.microsoft-surface-common
  ];

  hostSpec = {
    device = "/dev/nvme0n1";
    loader = "systemd";
    isMinimal = false;
    modules = {
      # server required modules
      virtualisation.enable = true;
      sshd.enable = true;
      # non-server modules
      printing.enable = true;
      audio.enable = true;
      bluetooth.enable = true;
      graphics.enable = true;
      nvidia.enable = true;
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
