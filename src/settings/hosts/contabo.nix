{...}: {
  imports = [./profiles/minimal.nix];
  
  module = {
    core = {
      boot = {
        loader = "grub";
        kernelPackage = "hardened";
        force = true;
      };

      persistence = {
        enable = true;
        disk = "/dev/sda"; 
        persistPath = "/persist";
      };
      
      networking = {
        networkManager.enable = false; 
        tcp.optimize = true;
        ssh = {
          enable = true;
          banner = ''
            █▄ █ █ ▀▄▀ █▀█ █▀▀
            █ ▀█ █ █ █ █▄█ ▄▄█
            
            Cloud Server - Authorized Access Only
          '';
        };
        firewall = {
          extraTcpPorts = [80 443];
          extraUdpPorts = [];
        };
      };
      
      locale = {
        timeZone = "UTC";
        defaultLocale = "en_US.UTF-8";
        keyboardLayout = "us";
      };
      
      security = {
        yubikey.enable = false;
        fail2ban = {
          enable = true; 
          maxRetry = 3; 
          banTime = "24h";
        };
      };
      
      virtualisation = {
        containers = {
          enable = true;
          backend = "podman";
        };
        libvirt.enable = false;
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

  # Server optimizations
  boot.kernelParams = [
    "noatime"
    "elevator=none"
  ];

  services.cloud-init = {
    enable = true;
    network.enable = true;
  };
}