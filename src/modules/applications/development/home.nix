{
  config,
  lib,
  pkgs,
  ctx,
  ...
}: let
  cfg = config.module.applications.development;
in {
  options.module.applications.development = {
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

      signingKey = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "GPG signing key";
      };
    };

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
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      [
        # Lightweight editing support
        pkgs.aspell # Spell checker
        pkgs.aspellDicts.en
        pkgs.aspellDicts.de
      ]
      ++ cfg.packages
      ++ lib.optionals ctx.gui cfg.packagesWithGUI;

    programs.git = {
      enable = true;
      userName = lib.mkIf (cfg.git.userName != "") cfg.git.userName;
      userEmail = lib.mkIf (cfg.git.userEmail != "") cfg.git.userEmail;
      signing = {
        key = cfg.git.signingKey;
        signByDefault = cfg.git.signingKey != "";
      };
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
    };

    programs.vscode = lib.mkIf cfg.editor.vscode.enable {
      enable = true;
      package = cfg.editor.vscode.package;
      profiles.default = {
        userSettings = {
          "editor.rulers" = [80 120];
          "editor.minimap.enabled" = false;
          "telemetry.telemetryLevel" = "off";
          "workbench.sideBar.location" = "right";
        };

        extensions = with pkgs.vscode-extensions; [
          ms-vscode-remote.remote-ssh
        ];
      };
    };

    programs.fzf = {
      enable = true;
      enableBashIntegration = true;
      defaultCommand = "fd --type f --hidden --follow --exclude .git";
      defaultOptions = ["--height 40%" "--border"];
    };

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

    home.sessionVariables = {
      PAGER = "less";
      LESS = "-R";
    };
  };
}
