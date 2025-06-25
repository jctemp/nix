{
  # Enable desktop-specific modules
  module = {
    core = {
      boot = {
        enable = true;
        loader = "systemd";
        force = false;
        kernelPackage = "default";
      };
      persistence = {
        enable = true;
        disk = "/dev/nvme0n1";
        persistPath = "/persist";
      };
      gnome.enable = true;
      audio.enable = true;
      printing.enable = true;
      networking = {
        enable = true;
        networkManager.enable = true;
      };
      security = {
        enable = true;
        yubikey.enable = true;
      };
      virtualisation = {
        enable = true;
        containers.enable = true;
        libvirt.enable = true;
      };
      users = {
        users = [];
        administrators = ["tmpl"];
      };
    };

    applications = {
      development.enable = true;
      media.enable = true;
      productivity.enable = true;
      terminal = {
        ghostty.enable = true;
        shell.enable = true;
        zellij.enable = true;
      };
      web.enable = true;
    };
  };
}
