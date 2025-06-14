{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.module.applications.terminal.shell;
in {
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
      default = "";
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
      completion.enable = cfg.enableCompletion;
      shellAliases = cfg.aliases;
      bashrcExtra = cfg.extraConfig;
    };

    programs.starship = lib.mkIf (cfg.prompt == "starship") {
      enable = true;
      enableBashIntegration = true;
      settings = builtins.fromTOML (builtins.readFile "./starship.toml");
    };

    programs.direnv = lib.mkIf cfg.enableDirenv {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };
  };
}
