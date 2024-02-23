{
  pkgs,
  username,
  stateVersion,
  ...
}: {
  home = {
    inherit username stateVersion;
    homeDirectory = "/home/${username}";
    packages = with pkgs; [
      firefox
      google-chrome
      keepassxc
      spotify

      # Development
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
      settings = builtins.fromTOML (builtins.readFile ./settings/hx-settings.toml);
    };

    starship = {
      enable = true;
      enableBashIntegration = true;
      settings = builtins.fromTOML (builtins.readFile ./settings/starship.toml);
    };

    vscode = {
      enable = true;
      extensions = with pkgs; [
        vscode-extensions.christian-kohler.path-intellisense
        vscode-extensions.github.copilot
        vscode-extensions.jnoortheen.nix-ide
        vscode-extensions.mkhl.direnv
        vscode-extensions.ms-pyright.pyright
        vscode-extensions.ms-python.black-formatter
        vscode-extensions.ms-python.python
        vscode-extensions.ms-python.vscode-pylance
        vscode-extensions.ms-toolsai.jupyter
        vscode-extensions.ms-toolsai.jupyter-renderers
        vscode-extensions.ms-toolsai.vscode-jupyter-cell-tags
        vscode-extensions.ms-toolsai.vscode-jupyter-slideshow
        vscode-extensions.ms-vscode-remote.remote-containers
        vscode-extensions.ms-vscode-remote.remote-ssh
        vscode-extensions.ms-vsliveshare.vsliveshare
        vscode-extensions.njpwerner.autodocstring
        vscode-extensions.nvarner.typst-lsp
        vscode-extensions.yzhang.markdown-all-in-one
        vscode-extensions.zhuangtongfa.material-theme
      ];
      mutableExtensionsDir = true;
      userSettings =
        (builtins.fromJSON (builtins.readFile ./settings/vscode.json))
        // {
          "terminal.integrated.defaultProfile.windows" = "${pkgs.bashInteractive}/bin/bash";
        };
    };

    home-manager.enable = true;
  };

  systemd.user.startServices = "sd-switch";
}
