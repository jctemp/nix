{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.nix-hardware.nixosModules.microsoft-surface-common
  ];

  hostSpec = {
    device = "/dev/nvme0n1";
    loader = "systemd";
  };
  modules = {
    security.yubikey.enable = true;
    services = {
      printing.enable = true;
      sshd.enable = true;
      fail2ban.enable = false;
      llm = {
        enable = true;
        acceleration = null;
        port = 4242;
      };
      stirling = {
        enable = true;
        port = 3256;
      };
      routing = {
        enable = true;
        local = {
          ollama = 4242;
          stirling = 3256;
        };
        extraConfig = "";
      };
    };
    hardware = {
      audio.enable = true;
      bluetooth.enable = true;
      nvidia.enable = true;
    };
    virtualisation = {
      containers.enable = true;
      libvirt.enable = true;
    };
    desktop.enable = true;
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
