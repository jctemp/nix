{
  pkgs,
  lib,
  ...
}: {
  nix = {
    # Use flakes and the new command-line interface
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
      keep-outputs = true;
      trusted-users = ["@wheel"];

      # Resource management
      connect-timeout = 5;
      log-lines = 25;
      min-free = 128000000; # 128MB
      max-free = 1000000000; # 1GB
    };
  };

  boot.tmp.cleanOnBoot = true;
  boot.kernelModules = ["tcp_bbr"];
  system.rebuild.enableNg = true;

  environment.systemPackages = lib.flatten [
    [
      pkgs.curl
      pkgs.jq
      pkgs.pciutils
      pkgs.tree
      pkgs.unzip
      pkgs.vim
      pkgs.zip
    ]
  ];

  documentation = {
    enable = true;
    dev.enable = true;
    doc.enable = false;
    info.enable = false;
    man.enable = true;
    nixos.enable = true;
  };

  virtualisation.vmVariant = {
    virtualisation.forwardPorts = [
      {
        from = "host";
        host.port = 8888;
        guest.port = 80;
      }
    ];

    # Hardware configuration for VMs
    diskSize = 32768; # 32 GB
    memorySize = 8192; # 8 GB
    cores = 4;
  };
}
