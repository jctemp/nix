_: {
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
}
