_: {
  hostSpec = {
    device = "/dev/sda";
    loader = "grub";
  };
  modules = {
    security.yubikey.enable = false;
    services = {
      printing.enable = false;
      sshd.enable = true;
    };
    hardware = {
      audio.enable = false;
      bluetooth.enable = false;
      nvidia.enable = false;
    };
    virtualisation = {
      containers.enable = true;
      libvirt.enable = false;
    };
    desktop.enable = false;
  };

  services.cloud-init.network.enable = true;
}
