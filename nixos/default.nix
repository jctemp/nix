{
  self,
  pkgs,
  version,
  ...
}: {
  imports = [
    "${self}/nixos/modules"
  ];

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
      trusted-users = ["root"];
    };
  };

  boot = {
    supportedFilesystems = ["ext4" "btrfs" "xfs" "ntfs" "fat" "vfat" "exfat"];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  environment = {
    systemPackages = with pkgs; [
      bat
      bottom
      curl
      du-dust
      eva
      fd
      felix-fm
      git
      helix
      mkpasswd
      ripgrep
      tree
      wget
    ];
    interactiveShellInit = ''
      export EDITOR=hx
      export VISUAL=hx
      export HISTSIZE=100000
    '';
  };

  system.stateVersion = "${version}";
}
