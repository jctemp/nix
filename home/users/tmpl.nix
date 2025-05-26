{
  inputs,
  pkgs,
  ...
}: let
  # Define language server packages
  lsp = {
    python = {
      ruff = pkgs.ruff;
      jedi = pkgs.python3Packages.jedi-language-server;
      pylsp = pkgs.python3Packages.python-lsp-server;
    };
    rust = pkgs.rust-analyzer;
    zig = pkgs.zls;
    c-cpp = pkgs.clang-tools;
    docker = pkgs.dockerfile-language-server-nodejs;
    bash = pkgs.nodePackages.bash-language-server;
    markdown = pkgs.marksman;
    typst = pkgs.tinymist;
    nix = pkgs.nixd;
  };

  # Define formatter packages (fmt.python = pkgs.ruff remains correct)
  fmt = {
    python = pkgs.ruff; # Keep ruff for formatting
    rust = pkgs.rustfmt;
    c-cpp = pkgs.clang-tools;
    bash = pkgs.shfmt;
    typst = pkgs.typstyle;
    zig = pkgs.zig;
    nix = pkgs.alejandra;
  };
in {
  home = {
    username = "tmpl";
    homeDirectory = "/home/tmpl";
    stateVersion = "24.11";
    file = {
      ".gnupg/gpg.conf" = {
        text = ''
          personal-cipher-preferences AES256 AES192 AES
          personal-digest-preferences SHA512 SHA384 SHA256
          personal-compress-preferences ZLIB BZIP2 ZIP Uncompressed
          default-preference-list SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed
          cert-digest-algo SHA512
          s2k-digest-algo SHA512
          s2k-cipher-algo AES256
          charset utf-8
          no-comments
          no-emit-version
          no-greeting
          keyid-format 0xlong
          list-options show-uid-validity
          verify-options show-uid-validity
          with-fingerprint
          require-cross-certification
          no-symkey-cache
          armor
          use-agent
          throw-keyids
        '';
      };
      ".gnupg/scdaemon.conf" = {
        enable = true;
        text = "disable-ccid";
      };
    };
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
    settings = builtins.fromTOML (builtins.readFile "${inputs.self}/home/settings/starship.toml");
  };
  programs.git = {
    enable = true;
    userName = "Jamie Temple";
    userEmail = "jamie.c.temple@gmail.com";
    signing.key = "6A89175BB28B8B81";
    signing.signByDefault = true;
  };
  programs.gitui = {
    enable = true;
    keyConfig = ''
      (
          move_left: Some(( code: Char('h'), modifiers: "")),
          move_right: Some(( code: Char('l'), modifiers: "")),
          move_up: Some(( code: Char('k'), modifiers: "")),
          move_down: Some(( code: Char('j'), modifiers: "")),
          stash_open: Some(( code: Char('l'), modifiers: "")),
          open_help: Some(( code: F(1), modifiers: "")),
          status_reset_item: Some(( code: Char('U'), modifiers: "SHIFT")),
      )
    '';
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
      theme = "ayu_dark";
      editor = {
        line-number = "absolute";
        true-color = true;
        rulers = [80 120];
        color-modes = true;
        end-of-line-diagnostics = "hint";
      };
      editor.inline-diagnostics = {
        cursor-line = "error";
        other-lines = "disable";
      };
      editor.indent-guides = {
        character = "╎";
        render = true;
      };
      editor.lsp = {
        enable = true;
        display-messages = true;
        display-inlay-hints = true;
      };
    };
    languages = {
      language-server = {
        ruff = {
          command = "${lsp.python.ruff}/bin/ruff";
          args = ["server"];
        };
        jedi = {command = "${lsp.python.jedi}/bin/jedi";};
        pylsp = {command = "${lsp.python.pylsp}/bin/pylsp";};
        rust-analyzer = {command = "${lsp.rust}/bin/rust-analyzer";};
        zls = {command = "${lsp.zig}/bin/zls";};
        clangd = {command = "${lsp.c-cpp}/bin/clangd";};
        docker-langserver = {
          command = "${lsp.docker}/bin/docker-langserver";
          args = ["--stdio"];
        };
        bash-language-server = {
          command = "${lsp.bash}/bin/bash-language-server";
          args = ["start"];
        };
        marksman = {
          command = "${lsp.markdown}/bin/marksman";
          # args = ["server"]; # Often not needed, marksman detects stdio mode
        };
        tinymist = {command = "${lsp.typst}/bin/tinymist";};
        nixd = {command = "${lsp.nix}/bin/nixd";};
      };

      language = let
        c-cpp-formatter = {
          command = "${fmt.c-cpp}/bin/clang-format";
          args = ["-style=file" "-assume-filename=%f"];
        };
      in [
        {
          name = "python";
          language-servers = ["ruff" "jedi" "pylsp"];
          formatter = {
            command = "${fmt.python}/bin/ruff";
            args = ["format" "--silent" "-"];
          };
          auto-format = true;
          comment-token = "#";
          roots = ["pyproject.toml" "setup.py" "poetry.lock" "pyrightconfig.json"];
          shebangs = ["python" "uv"];
          scope = "source.python";
          file-types = ["py" "pyi" "py3" "pyw" "ptl" "rpy" "cpy" "ipy" "pyt" {glob = ".python_history";} {glob = ".pythonstartup";} {glob = ".pythonrc";} {glob = "*SConstruct";} {glob = "*SConscript";} {glob = "*sconstruct";}];
        }
        {
          name = "rust";
          language-servers = ["rust-analyzer"];
          formatter = {
            command = "${fmt.rust}/bin/rustfmt";
          };
          auto-format = true;
          roots = ["Cargo.toml" "Cargo.lock"];
          shebangs = ["rust-script" "cargo"];
          # persistent-diagnostic-sources = ["rustc" "clippy"];
        }
        {
          name = "zig";
          language-servers = ["zls"];
          formatter = {
            command = "${fmt.zig}/bin/zig";
            args = ["fmt" "--stdin"];
          };
          auto-format = true; # LSP often handles this via 'zig fmt'
        }
        {
          name = "c";
          language-servers = ["clangd"];
          formatter = c-cpp-formatter; # Use the shared formatter config
          auto-format = true;
        }
        {
          name = "cpp";
          language-servers = ["clangd"];
          formatter = c-cpp-formatter; # Use the shared formatter config
          auto-format = true;
        }
        {
          name = "dockerfile";
          language-servers = ["docker-langserver"];
          auto-format = false; # No standard formatter applied
        }
        {
          name = "bash";
          language-servers = ["bash-language-server"];
          formatter = {
            command = "${fmt.bash}/bin/shfmt";
          };
          auto-format = true;
        }
        {
          name = "markdown";
          language-servers = ["marksman"];
          auto-format = false;
        }
        {
          name = "typst";
          language-servers = ["tinymist"];
          formatter = {
            command = "${fmt.typst}/bin/typstyle";
            args = ["format" "-"];
          };
          auto-format = true;
        }
        {
          name = "nix";
          language-servers = ["nixd"];
          formatter = {command = "${fmt.nix}/bin/alejandra";};
          auto-format = true;
        }
      ];
    };
  };
  programs.zellij = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      simplified_ui = true;
      copy_command = "${pkgs.xclip}/bin/xclip -sel clipboard";
      theme = "ayu_dark";
      show_startup_tips = false;
    };
  };
  programs.ghostty = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      theme = "ayu";
      font-size = 12;
      maximize = true;
    };
  };
  programs.chromium = {
    enable = true;
    package = pkgs.google-chrome;
  };
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    profiles.default.userSettings = {
      # --- General settings
      "editor.inlayHints.enabled" = "on";
      "editor.rulers" = [80 120];
      "workbench.colorTheme" = "Catppuccin Macchiato";
      "workbench.iconTheme" = "catppuccin-macchiato";
      "workbench.sideBar.location" = "right";
      "terminal.integrated.profiles.linux" = {
        "bash" = {
          "path" = "${pkgs.bashInteractive}/bin/bash";
          "icon" = "terminal-bash";
        };
      };
      "terminal.integrated.defaultProfile.linux" = "bash";
      "editor.formatOnSave" = true;

      # --- Telemetry ---
      "telemetry.telemetryLevel" = "off";

      # --- Languages ---
      "[python]" = {
        "editor.defaultFormatter" = "charliermarsh.ruff";
        "terminal.activateEnvironment" = true;
      };
      "[rust]" = {
        "editor.defaultFormatter" = "rust-lang.rust-analyzer";
      };
      "[c]" = {
        "editor.defaultFormatter" = "llvm-vs-code-extensions.vscode-clangd";
      };
      "[cpp]" = {
        "editor.defaultFormatter" = "llvm-vs-code-extensions.vscode-clangd";
      };
      "[shellscript]" = {
        "editor.defaultFormatter" = "foxundermoon.shell-format";
      };
      "[typst]" = {
        "editor.defaultFormatter" = "myriad-dreamin.tinymist";
      };
      "[zig]" = {
        "editor.defaultFormatter" = "ziglang.vscode-zig";
      };
      "[nix]" = {
        "editor.defaultFormatter" = "jnoortheen.nix-ide";
      };
      "[markdown]" = {
        "editor.formatOnSave" = false;
      };
      "nix.formatterPath" = "alejandra";
      "nix.serverPath" = "nixd";
      "python.terminal.activateEnvironment" = true;
    };
    profiles.default.extensions = with pkgs; [
      # --- Themes ---
      vscode-extensions.catppuccin.catppuccin-vsc
      vscode-extensions.catppuccin.catppuccin-vsc-icons

      # --- Languages ---
      # Python
      vscode-extensions.charliermarsh.ruff
      vscode-extensions.ms-pyright.pyright
      vscode-extensions.ms-python.python
      vscode-extensions.ms-toolsai.jupyter
      vscode-extensions.ms-toolsai.jupyter-keymap
      vscode-extensions.ms-toolsai.jupyter-renderers
      vscode-extensions.ms-toolsai.vscode-jupyter-cell-tags
      vscode-extensions.ms-toolsai.vscode-jupyter-slideshow

      # Rust
      vscode-extensions.rust-lang.rust-analyzer

      # Zig
      vscode-extensions.ziglang.vscode-zig

      # C/C++
      vscode-extensions.ms-vscode.cmake-tools
      vscode-extensions.llvm-vs-code-extensions.vscode-clangd

      # Dockerfiles
      vscode-extensions.ms-azuretools.vscode-docker

      # Bash/Shell script
      vscode-extensions.mads-hartmann.bash-ide-vscode
      vscode-extensions.foxundermoon.shell-format
      vscode-extensions.timonwong.shellcheck

      # Markdown
      vscode-extensions.yzhang.markdown-all-in-one

      # Typst (LSP via tinymist, formatting via typstyle)
      vscode-extensions.myriad-dreamin.tinymist

      # Nix (LSP via nixd, Formatting via alejandra)
      vscode-extensions.jnoortheen.nix-ide

      # --- Other Extensions ---
      vscode-extensions.ms-vscode-remote.remote-ssh
      vscode-extensions.ms-vsliveshare.vsliveshare
    ];
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
    gitkraken

    # LSPs
    lsp.python.ruff
    lsp.python.pylsp
    lsp.python.jedi
    lsp.rust
    lsp.zig
    lsp.c-cpp # Provides clangd
    lsp.docker
    lsp.bash
    lsp.markdown
    lsp.typst # tinymist
    lsp.nix

    # Formatters / Tools providing formatters
    fmt.python # ruff
    fmt.rust # rustfmt
    fmt.bash # shfmt
    fmt.typst # typstyle
    fmt.zig # zig itself
    fmt.nix

    # Dependencies
    pkgs.nodejs

    # Jupyter support (core packages)
    pkgs.python3Packages.jupyter-core
    pkgs.python3Packages.ipykernel
  ];
}
