{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    curl
    gnome.nautilus
    ripgrep
    tree
    vim
    wget
  ];
  programs.git = {
    enable = true;
    lfs.enable = true;
    config.init.defaultBranch = "main";
  };
}
