_: {
  hostSpec = {
    device = "/dev/nvme0n1";
    loader = "systemd";
    isMinimal = false;
    modules = {
      # server required modules
      virtualisation.enable = true;
      gnupg.enable = true;
      ssh.enable = true;
      sshd.enable = true;
      yubikey.enable = true;
      # non-server modules
      printing.enable = true;
      audio.enable = true;
      bluetooth.enable = true;
      graphics.enable = true;
      nvidia.enable = true;
    };
  };
}
