# src/modules/applications/development/home.nix
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.module.applications.development;
in {
  # Home-specific options only
  options.module.applications.development = {
    # Git user configuration
    git = {
      userName = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Git user name";
      };

      userEmail = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Git user email";
      };

      signing = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable commit signing";
        };

        key = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "GPG signing key";
        };
      };

      applications = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [];
        description = "Git GUI applications to install";
      };
    };

    # Editor user configuration
    editor = {
      helix = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable Helix editor configuration";
        };

        defaultEditor = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Set Helix as default editor";
        };

        theme = lib.mkOption {
          type = lib.types.str;
          default = "ayu_dark";
          description = "Helix color theme";
        };
      };

      vscode = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable VS Code configuration";
        };

        defaultEditor = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Set VS Code as default editor";
        };

        package = lib.mkOption {
          type = lib.types.package;
          default = pkgs.vscode;
          description = "VS Code package to use";
        };
      };
    };

    # Additional user packages
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Extra development packages for user";
    };
  };

  config = lib.mkIf cfg.enable {
    # User development packages
    home.packages =
      [
        # Enhanced CLI tools
        pkgs.zoxide # Better cd
        pkgs.fzf # Fuzzy finder

        # Development utilities
        pkgs.gh # GitHub CLI

        # System monitoring
        pkgs.duf # Better df
        pkgs.ncdu # Disk usage

        # Lightweight editing
        pkgs.marksman # Markdown LSP (lightweight)
        pkgs.vale # Prose linter
      ]
      ++ cfg.git.applications ++ cfg.extraPackages;

    # Git configuration (user-specific)
    programs.git = {
      enable = true;
      userName = lib.mkIf (cfg.git.userName != "") cfg.git.userName;
      userEmail = lib.mkIf (cfg.git.userEmail != "") cfg.git.userEmail;
      signing = lib.mkIf cfg.git.signing.enable {
        key = cfg.git.signing.key;
        signByDefault = true;
      };
    };

    # GitUI configuration
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

    # Helix configuration
    programs.helix = lib.mkIf cfg.editor.helix.enable {
      enable = true;
      defaultEditor = cfg.editor.helix.defaultEditor;

      settings = {
        theme = cfg.editor.helix.theme;

        editor = {
          line-number = "absolute";
          true-color = true;
          rulers = [80 120];
          color-modes = true;
          end-of-line-diagnostics = "hint";
          auto-pairs = true;
          auto-completion = true;
          auto-format = true;

          indent-guides = {
            render = true;
            character = "|";
          };

          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };

          search = {
            smart-case = true;
            wrap-around = true;
          };

          file-picker = {
            hidden = false;
            follow-symlinks = true;
            git-ignore = true;
          };
        };
      };

      # Minimal language configuration - NO LSP servers
      languages = {
        language = [
          {
            name = "markdown";
            file-types = ["md" "markdown"];
            comment-token = "<!--";
            auto-format = false;
          }
          {
            name = "bash";
            file-types = ["sh" "bash"];
            shebangs = ["sh" "bash"];
            comment-token = "#";
          }
          {
            name = "nix";
            file-types = ["nix"];
            comment-token = "#";
          }
          {
            name = "json";
            file-types = ["json"];
          }
          {
            name = "yaml";
            file-types = ["yml" "yaml"];
            comment-token = "#";
          }
        ];

        # NO language servers - all come from devshells
        language-server = {};
      };
    };

    # VS Code configuration
    programs.vscode = lib.mkIf cfg.editor.vscode.enable {
      enable = true;
      package = cfg.editor.vscode.package;
      profiles.default = {
        userSettings = {
          # Universal VS Code settings only
          "workbench.colorTheme" = "Ayu Dark Bordered";
          "editor.rulers" = [80 120];
          "editor.minimap.enabled" = false;
          "telemetry.telemetryLevel" = "off";

          # NO language-specific settings
          # NO formatters, linters, language servers
        };

        extensions = with pkgs.vscode-extensions; [
          # Universal extensions only
          teabyii.ayu
          vscodevim.vim # Vim bindings
          ms-vscode-remote.remote-ssh # Remote development

          # NO language-specific extensions
        ];
        };
      };

    # Shell configuration (user-level enhancements)
    programs.bash = {
      enable = true;
      enableCompletion = true;

      shellAliases = {
        # Home manager
        system-rebuild = "sudo nixos-rebuild switch";
        home-rebuild = "home-manager switch";

        # Markdown shortcuts
        mdview = "glow";
        mdlint = "vale";
      };

      bashrcExtra = ''
        # Enhanced development environment
        export HISTSIZE=10000
        export HISTFILESIZE=20000
        export HISTCONTROL=ignoreboth:erasedups

        # Development tools
        ${lib.optionalString cfg.editor.helix.defaultEditor ''export EDITOR="hx"''}
        ${lib.optionalString cfg.editor.vscode.defaultEditor ''export EDITOR="code"''}
        export BROWSER="firefox"
        export NIX_CONFIG="experimental-features = nix-command flakes"
      '';
    };

    # Nushell configuration
    programs.nushell = {
      enable = true;

      configFile.text = ''
        $env.config = {
          show_banner: false
          edit_mode: vi
          completions: {
            case_sensitive: false
            quick: true
            partial: true
          }
        }

        # Development aliases
        alias ll = ls -la
        alias la = ls -la
        alias gst = git status
        alias gd = git diff
        alias gl = git log --oneline -10
      '';

      envFile.text = ''
        ${lib.optionalString cfg.editor.helix.defaultEditor ''$env.EDITOR = "hx"''}
        ${lib.optionalString cfg.editor.vscode.defaultEditor ''$env.EDITOR = "code"''}
        $env.NIX_CONFIG = "experimental-features = nix-command flakes"
      '';
    };

    # Essential development tools
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      config = {
        warn_timeout = "1h";
        load_dotenv = true;
      };
    };

    programs.zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
    };

    programs.fzf = {
      enable = true;
      enableBashIntegration = true;
      defaultCommand = "fd --type f --hidden --follow --exclude .git";
      defaultOptions = ["--height 40%" "--border"];
    };

    # Configuration files
    xdg.configFile = {
      # Global gitignore
      "git/ignore".text = ''
        # Editor files
        .vscode/
        .idea/
        *.swp
        *.swo
        *~

        # OS files
        .DS_Store
        Thumbs.db

        # Development environment
        .direnv/
        .envrc.local

        # Logs and temporary files
        *.log
        *.tmp
        *.temp
      '';

      # Vale configuration
      "vale/vale.ini".text = ''
        StylesPath = styles
        MinAlertLevel = suggestion

        [*.{md,txt}]
        BasedOnStyles = Vale, write-good
      '';

      # Marksman configuration
      "marksman/config.toml".text = ''
        [core]
        markdown.file_extensions = ["md", "markdown"]

        [completion]
        wiki.style = "title-slug"
      '';

      # Helix ignore patterns
      "helix/ignore" = lib.mkIf cfg.editor.helix.enable {
        text = ''
          .git/
          node_modules/
          target/
          .direnv/
          result
          result-*
          *.tmp
          *.log
        '';
      };
    };

    # Session variables
    home.sessionVariables = {
      EDITOR = lib.mkIf cfg.editor.helix.defaultEditor "hx";
      PAGER = "less";
      LESS = "-R";
      NIX_CONFIG = "experimental-features = nix-command flakes";
    };
  };
}
