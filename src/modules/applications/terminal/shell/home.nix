{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.module.applications.terminal.shell;
in {
  # TODO: add nushull and make it the primary shell to use
  options.module.applications.terminal.shell = {
    applications = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Shell applications to install for user";
    };

    prompt = lib.mkOption {
      type = lib.types.enum ["starship" "basic"];
      default = "starship";
      description = "Shell prompt to use";
    };

    aliases = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {
        system-rebuild = "sudo nixos-rebuild switch";
        home-rebuild = "home-manager switch";

        # color support
        ls = "ls --color=auto";
        dir = "dir --color=auto";
        vdir = "vdir --color=auto";
        grep = "grep --color=auto";
        fgrep = "fgrep --color=auto";
        egrep = "egrep --color=auto";

        # modified commands
        df = "df -h";
        du = "du -h";
        free = "free -h";
        less = "less -i";
        mkdir = "mkdir -pv";
        ping = "ping -c 3";
        ".." = "cd ..";
      };
      description = "Shell aliases";
    };

    enableCompletion = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable shell completion";
    };

    enableDirenv = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable direnv for development environments";
    };

    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = ''
        export HISTSIZE=10000
        export HISTFILESIZE=20000
        export HISTCONTROL=ignoreboth:erasedups
      '';
      description = "Extra shell configuration";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs;
      [
        bat
        ripgrep
      ]
      ++ cfg.applications;

    programs.bash = {
      enable = true;
      inherit (cfg) enableCompletion;
      shellAliases = cfg.aliases;
      bashrcExtra = cfg.extraConfig;
    };

    programs.starship = lib.mkIf (cfg.prompt == "starship") {
      enable = true;
      enableBashIntegration = true;
      settings = builtins.fromTOML (builtins.readFile "${inputs.self}/src/modules/applications/terminal/shell/starship.toml");
    };

    programs.direnv = lib.mkIf cfg.enableDirenv {
      enable = true;
      enableBashIntegration = true;
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
  };
}
