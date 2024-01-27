{
  self,
  config,
  pkgs,
  modulesPath,
  lib,
  ...
}: {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  nix.settings = {
      experimental-features = "nix-command flakes";
      trusted-users = ["root"];
  };

  boot = {
    kernelPackages = pkgs.zfs.latestCompatibleLinuxPackages;
    supportedFilesystems = lib.mkForce ["btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" "zfs"];
    initrd.supportedFilesystems = ["zfs"];
    zfs = {
      forceImportAll = false;
      forceImportRoot = false;
    };
  };

  users.users.root = {
    password = "";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDAKBMLlQ1VqxL+ymyzCsmUjSUbe9xlWnH6XTObdazuuxWlJJmKTnHr9NoiaC7Zz10OtI8jSSTm+69RHRpl1IEimPU/YV8cKFSDLUvhxHGRC+mGjpmJl1/mY7mOAFghvpz7lhgn9UQZuU0rxD/PeciwA3v5ryGr0ZNyIdHvWVhlgugUPps0mjhKzdabHM0k1518wKJSsPmP4EJzG08Z6KYrxodwgPLVz3WNuHx0zVrM2SqR5CK1sLjJ+tMOS+TDz0bMEEBTHrz1sbPQXKglK+MIVFPTPNmqugaUm2FWRN4PISGNy0H8sxtOe4mFOl/6MUYBO7gi4544o4q5LCyCWnQ34WxJriyAwCL4x9IfRYupsZ5aEuRh48v+YE8lSg2rVa5P+E9FuhXFZDLq4jozn+vxHeUkH4aAWV5cblsp+FcHiisR/ySs0DLyylFppdUDPCOTzOcGLuyYIIkUFTCUpWu443ls0ucz+gjbcLSwAyVhCklzenf3ffTZ35MuhXPHICQ/tahyN4mRFuyCB0zrsafnHnTWtKbtMKtMBDEwpov36pkqUA4U8ROTBo11CMo2HBuc6ycM8AKLt1iIc1lYHTufXmuwDifva3O5Ivto+42C0ka6JbzlygqW1WC3nZpycF0Dz9ow4zzeDXmDkto6L7YblTJVuJy6gKELKnKobVD75Q== cardno:17_735_414"
    ];
  };

  environment = {
    systemPackages = with pkgs; [
      neovim
      git
      jq
    ];
    interactiveShellInit = ''
      export EDITOR=nvim
      export VISUAL=nvim
      export HISTSIZE=100000
      export CONFIG_PATH=${self}
    '';
  };

  networking = {
    hostName = "installer";
    hostId = "ffffffff";
    useDHCP = true;
    wireless.enable = false;
    firewall = {
      enable = true;
      allowedTCPPorts = [];
      allowedUDPPorts = [];
    };
  };

  services = {
    openssh = {
      enable = true;
      banner = ''
        █ █▄ █ █▀▀ ▀█▀ ▄▀█ █   █   █▀▀ █▀█
        █ █ ▀█ ▄▄█  █  █▀█ █▄▄ █▄▄ ██▄ █▀▄
        Powered by NixOS
      '';
      allowSFTP = true;
      openFirewall = true;
      settings.PasswordAuthentication = true;
      settings.PermitRootLogin = "yes";
    };
  };
  system.stateVersion = "23.11";
}
