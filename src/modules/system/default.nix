{
  pkgs,
  utils,
  ...
}: {
  imports = [
    ./audio.nix
    ./boot.nix
    ./gnome.nix
    ./locale.nix
    ./networking.nix
    ./persistence.nix
    ./printing.nix
    ./security.nix
  ];

  config = utils.mkIfSystem {
    nix = {
      settings = {
        experimental-features = "nix-command flakes";
        auto-optimise-store = true;
        keep-outputs = true;
        trusted-users = ["@wheel"];

        connect-timeout = 5;
        log-lines = 25;
        min-free = 128000000; # 128MB
        max-free = 1000000000; # 1GB
      };
    };

    boot.tmp.cleanOnBoot = true;
    boot.kernelModules = ["tcp_bbr"];
    system.rebuild.enableNg = true;

    environment.systemPackages = with pkgs; [
      curl
      git
      tree
      vim

      file
      pciutils
      usbutils

      unzip
      zip
      jq
    ];

    fonts.packages = with pkgs; [
      ubuntu-sans-mono
    ];

    documentation = {
      enable = true;
      doc.enable = false;
      info.enable = false;
      man.enable = true;
    };

    console = {
      # font = "Lat2-Terminus16";
      useXkbConfig = false;
      earlySetup = true;
    };
  };
}
