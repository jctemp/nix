# src/modules/applications/development/system.nix
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.module.applications.development;
in {
  # System-specific options only
  options.module.applications.development = {
    # Core system development tools
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Extra system-wide development packages";
    };

    # Editor system configuration
    editor = {
      helix = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Install Helix editor system-wide";
        };

        extraPackages = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [];
          description = "Extra helix packages to install system-wide";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Essential development tools (always installed)
    environment.systemPackages =
      [
        # Version control
        pkgs.git
        pkgs.git-lfs

        # Environment management
        pkgs.direnv
        pkgs.nix-direnv

        # Universal utilities
        pkgs.ripgrep
        pkgs.fd
        pkgs.tree
        pkgs.jq
        pkgs.yq-go
        pkgs.curl
        pkgs.wget

        # System monitoring
        pkgs.htop
        pkgs.btop

        # Basic editors (always available)
        pkgs.vim
        pkgs.nano

        # Text processing
        pkgs.bat
        pkgs.eza

        # System shells
        pkgs.bash
        pkgs.bashInteractive
        pkgs.nushell

        # Lightweight editing support
        pkgs.glow # Markdown viewer
        pkgs.aspell # Spell checker
        pkgs.aspellDicts.en
        pkgs.aspellDicts.de
      ]
      ++ cfg.extraPackages
      ++ lib.optionals cfg.editor.helix.enable ([pkgs.helix] ++ cfg.editor.helix.extraPackages);

    # System environment variables
    environment.variables = {
      # Nix development
      NIX_CONFIG = "experimental-features = nix-command flakes";

      # Set default editor if Helix is enabled
      EDITOR = lib.mkIf cfg.editor.helix.enable "${pkgs.helix}/bin/hx";
    };

    # System Git configuration
    programs.git = {
      enable = true;
      lfs.enable = true;
      prompt.enable = true;
      config = {
        color.ui = true;
        grep.lineNumber = true;
        init.defaultBranch = "main";
        core = {
          autocrlf = "input";
          editor = lib.mkIf cfg.editor.helix.enable "${pkgs.helix}/bin/hx";
        };
        diff = {
          mnemonicprefix = true;
          rename = "copy";
        };
        url = {
          "https://github.com/" = {
            insteadOf = [
              "gh:"
              "github:"
            ];
          };
        };
      };
    };

    programs.bash = {
      completion.enable = true;

      shellAliases = {
        ll = "eza -la";
        la = "eza -la";
        tree = "eza --tree";
        cat = "bat";

        nix-search = "nix search nixpkgs";
        nix-gc = "nix-collect-garbage -d";

        ".." = "cd ..";
        "..." = "cd ../..";
      };
    };
  };
}
