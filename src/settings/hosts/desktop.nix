{...}: {
  imports = [./profiles/full.nix];
  
  module = {
    core = {
      boot = {
        loader = "systemd";
        kernelPackage = "default";
      };
      
      persistence = {
        enable = true;
        disk = "/dev/nvme0n1";
        persistPath = "/persist";
      };
      
      networking = {
        networkManager.enable = true;
        tcp.optimize = true;
        ssh.enable = false;
      };
      
      locale = {
        timeZone = "Europe/Berlin";
        defaultLocale = "en_US.UTF-8";
        extraLocale = "de_DE.UTF-8";
        keyboardLayout = "us";
      };
      
      security = {
        yubikey.enable = true;
        fail2ban.enable = false;
      };
      
      virtualisation = {
        containers = {
          enable = true;
          backend = "podman";
        };
        libvirt.enable = true;
      };
      
      users = {
        administrators = ["tmpl"];
        primaryUser = "tmpl";
      };
    };

    applications = {
      development.enable = true;
    };
  };
}