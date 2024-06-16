{
  self,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix

    "${self}/modules/base.nix"
    "${self}/modules/boot/systemd.nix"
    "${self}/modules/nvidia.nix"
    "${self}/modules/gnome.nix"
    "${self}/modules/media/all.nix"
  ];

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
