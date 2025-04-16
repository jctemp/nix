{pkgs, ...}: {
  home = {
    username = "tmpl";
    homeDirectory = "/home/tmpl";
    stateVersion = "24.11";
  };

  programs.home-manager.enable = true;
  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      ll = "ls -lash";
      l = "ls -lA";
      la = "ls -la";
    };
  };
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    settings = {}; # TODO: integrate toml configuration
  };
  programs.git = {
    enable = true;
    userName = "Jamie Temple";
    userEmail = "jamie.c.temple@gmail.com";
    signing.key = "6A89175BB28B8B81";
    signing.signByDefault = true;
  };
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };
  programs.helix = {
    enable = true;
    defaultEditor = true;
    settings = {
      theme = "catppuccin_macchiato";
      editor = {
        line-number = "absolute";
        true-color = true;
        rulers = [80 120];
        color-modes = true;
        end-of-line-diagnostic = "hint";
      };
      editor.inline-diagnostic = {
        cursor-line = "error";
        other-line = "disable";
      };
      editor.indent-guide = {
        character = "╎";
        render = true;
      };
      editor.lsp = {
        enable = true;
        display-messages = true;
        display-inlay-hints = true;
      };
    };
  };
  programs.ghostty = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      theme = "catppuccin-macchiato";
      font-size = 12;
    };
  };
  programs.chromium = {
    enable = true;
    package = pkgs.google-chrome;
  };
  home.packages = with pkgs; [
    # CLI tools
    htop
    ripgrep
    fd
    jq

    # GUI applications
    keepassxc
    spotify
    zotero
    blender_4_3
    freecad
  ];
}
