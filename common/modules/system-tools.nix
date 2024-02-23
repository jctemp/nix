{pkgs, ...}: {
  environment = {
    systemPackages = with pkgs; [
      alacritty
      bat
      curl
      git
      gnome.nautilus
      neovim
      ripgrep
      tree
      wget
    ];
    interactiveShellInit = ''
      export EDITOR=nvim
      export VISUAL=nvim
      export HISTSIZE=100000
    '';
  };
}
