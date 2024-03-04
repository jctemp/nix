{
  self,
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
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDKzE8tMyXIM8Fq/9/ubwP9tlqL0WTlZ7NBF4pcO/p3T7AZD2W9W2c/tzbnk/GeqOKEF94VLO1dmHOAUW3WjbjgdtLhnVetSLTfYYUYYSPueX56FBHN8734kQRaYQ0jGMTA8TnH+dnZo6N1wdZZx/yIEyCQ4+N6EdNGxq9Y35joepubZL3LuaHWJj3BTswYorrDwRvkVaEFSS3CLGHWxOmey7dt7GAvKz2rod6uA4jZjbXzFSfMdyXq7/t1uclxHYPwd3imoMCtf67qn/qRs7S6v6vE3d5+XnMYMjDKAjv9uPw2O3DpdEgCfgUIkDYJ6u7aJ9DkLRpTNm2XVTKXqcWwVyKvR8SiprchJGge+mSC+GIooHvylzPxR+NyI/iZIcR2HO4kxHymTYoV4NEAr5LCT5Vew9QyIB9nyf5UJt4zYr9CJ8gCsK/oBeOBJeeAzZuH6/A4Zxt8gt6vtJ46eXk+gHFsF+YODtBMHrSR0TGODcWu3oz+Jmm+LtPbbbUR75kWjvnPr+H8jmgo3U/DGFHZij1XpGRapr7xMHRlah6lE7sIWk2Kb4zAMvw8yZqrMd0wA+UwpVYgGIZhjHP2SklwZig9hLjAQvXsWK2fbz6vvARWQ+6jRSMvYDEWf9LUP86gj+q+oKxkcQLad43ygzNK9RRBCYzSDNt8uB23DrXnkw== openpgp:0x63921A88"
    ];
  };

  environment = {
    systemPackages = with pkgs; [
      (writeShellScriptBin "host-install" (builtins.readFile ./host-install))
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
