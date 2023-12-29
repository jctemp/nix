{pkgs, ...}: let
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec -a "$0" "$@"
  '';
in {
  # Use the Gnome
  environment.systemPackages = [nvidia-offload];

  services.xserver = {
    enable = true;
    layout = "us";

    desktopManager.gnome.enable = true;
    displayManager = {
      defaultSession = "gnome";
      gdm.enable = true;
      gdm.wayland = true;
    };
  };

  # Enable NVIDIA drivers
  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        rocmPackages.clr.icd
        intel-compute-runtime
        intel-media-driver
        ocl-icd
      ];
    };
    nvidia = {
      modesetting.enable = true;
      nvidiaSettings = true;
      open = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      # prime = {
      #   offload = {
      #     enable = true;
      #     enableOffloadCmd = true;
      #   };
      #   intelBusId = "PCI:0:2:0";
      #   nvidiaBusId = "PCI:1:0:0";
      # };
    };
  };

  services.xserver.videoDrivers = ["nvidia"];
}
