_: {
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
}
