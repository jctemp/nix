{
  pkgs,
  username,
  version,
  ...
}: {
  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    packages = with pkgs; [
      firefox
      google-chrome
      keepassxc
      spotify
    ];
    stateVersion = version;
  };

  programs = {
    alacritty = {
      enable = true;
      settings = {
        window.padding = {
          x = 5;
          y = 5;
        };
        scrolling.history = 10000;
      };
    };

    bash = {
      enable = true;
      enableCompletion = true;
      shellAliases = {
        ll = "ls -l";
        l = "ls -lA";
        la = "ls -la";
      };
    };

    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };

    git = {
      enable = true;
      userName = "Jamie Temple";
      userEmail = "jamie-temple@live.de";
      signing.key = "1F7AD43C1F17EC41";
      signing.signByDefault = true;
    };

    gh.enable = true;

    git-cliff = {
      enable = true;
      settings.git = {
        conventional_commits = true;
        filter_unconventional = true;
        split_commits = false;
      };
    };

    gitui = {
      enable = true;
      keyConfig = ./settings/gitui.ron;
    };

    helix = {
      enable = true;
      defaultEditor = true;
      extraPackages = with pkgs; [
        lldb
        clang-tools
        cmake-language-server
        dockerfile-language-server-nodejs
        gopls
        haskell-language-server
        marksman
        nil
        nodePackages.bash-language-server
        nodePackages.typescript-language-server
        nodePackages.vscode-langservers-extracted
        ocamlPackages.dune_3
        ocamlPackages.ocaml-lsp
        ocamlPackages.reason
        opam
        python311Packages.python-lsp-server
        rust-analyzer
        swiProlog
        taplo
        texlab
        texlab
        typst-lsp
        yaml-language-server
        zls
      ];
      settings = builtins.fromTOML (builtins.readFile ./settings/hx-settings.toml);
    };

    starship = {
      enable = true;
      enableBashIntegration = true;
      settings = builtins.fromTOML (builtins.readFile ./settings/starship.toml);
    };

    # zellij = {
    #   enable = true;
    #   enableBashIntegration = true;
    #   settings = {
    #     simplified_ui = true;
    #   };
    # };

    home-manager.enable = true;
  };

  systemd.user.startServices = "sd-switch";
}
