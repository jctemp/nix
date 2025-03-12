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
      fail2ban.enable = true;
      llm = {
        enable = false;
        acceleration = null;
        port = 4242;
      };
      stirling = {
        enable = false;
        port = 3256;
      };
      routing = {
        enable = false;
        local = {
        };
        extraConfig = "";
      };
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
