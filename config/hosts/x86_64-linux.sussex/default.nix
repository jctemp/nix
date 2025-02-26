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
