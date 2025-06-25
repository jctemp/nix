{
  # Enable server-specific modules
  module = {
    core = {
      audio.enable = false; # No audio on server
      printing.enable = false; # No printing on server
      networking = {
        enable = true;
        networkManager.enable = false; # Use systemd-networkd
        ssh.enable = true;
      };
      security = {
        enable = true;
        fail2ban.enable = true; # Important for servers
      };
      virtualisation = {
        enable = true;
        containers.enable = true;
        libvirt.enable = false; # No VMs on cloud
      };
    };

    applications = {
      development = {
        git.enable = true;
        helix.enable = true;
      };
      terminal = {
        shell.enable = true;
        zellij.enable = true;
      };
      # No GUI applications
    };
  };

  # Minimal hardware for server
  hardware = {
    nvidia.enable = false;
    bluetooth.enable = false;
  };

  # Server optimizations
  boot.kernelParams = [
    "noatime"
    "elevator=none"
  ];
}
